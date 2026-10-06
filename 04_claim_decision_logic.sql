USE healthinsurancedb;

-- =========================================================
-- 04_CLAIM_DECISION_LOGIC.SQL
-- EXPLAINABLE CLAIM DECISION SYSTEM
-- =========================================================

DROP PROCEDURE IF EXISTS EvaluateClaim;

DELIMITER $$

CREATE PROCEDURE EvaluateClaim(IN p_claim_id INT)

BEGIN

    -- =====================================================
    -- VARIABLES
    -- =====================================================

    DECLARE v_policy_id INT;
    DECLARE v_hospital_id INT;
    DECLARE v_treatment_id INT;

    DECLARE v_claim_amount DECIMAL(12,2);
    DECLARE v_admission_date DATE;
    DECLARE v_discharge_date DATE;

    DECLARE v_policy_status VARCHAR(20);
    DECLARE v_policy_start DATE;
    DECLARE v_policy_end DATE;
    DECLARE v_sum_insured DECIMAL(12,2);
    DECLARE v_plan_id INT;

    DECLARE v_treatment_covered INT DEFAULT 0;
    DECLARE v_coverage_percentage DECIMAL(5,2) DEFAULT 0;
    DECLARE v_treatment_limit DECIMAL(12,2) DEFAULT 0;

    DECLARE v_remaining_coverage DECIMAL(12,2) DEFAULT 0;
    DECLARE v_eligible_amount DECIMAL(12,2) DEFAULT 0;

    DECLARE v_duplicate_count INT DEFAULT 0;

    DECLARE v_document_count INT DEFAULT 0;
    DECLARE v_unverified_documents INT DEFAULT 0;

    DECLARE v_decision VARCHAR(30);
    DECLARE v_risk_level VARCHAR(20);

    -- =====================================================
    -- GET CLAIM DETAILS
    -- =====================================================

    SELECT
        policy_id,
        hospital_id,
        treatment_id,
        claim_amount,
        admission_date,
        discharge_date
    INTO
        v_policy_id,
        v_hospital_id,
        v_treatment_id,
        v_claim_amount,
        v_admission_date,
        v_discharge_date
    FROM Claim
    WHERE claim_id = p_claim_id
    LIMIT 1;


    -- =====================================================
    -- CHECK WHETHER CLAIM EXISTS
    -- =====================================================

    IF v_policy_id IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Claim ID does not exist';

    END IF;


    -- =====================================================
    -- GET POLICY DETAILS
    -- =====================================================

    SELECT
        status,
        start_date,
        end_date,
        sum_insured,
        plan_id
    INTO
        v_policy_status,
        v_policy_start,
        v_policy_end,
        v_sum_insured,
        v_plan_id
    FROM Policy
    WHERE policy_id = v_policy_id;


    -- =====================================================
    -- CHECK TREATMENT COVERAGE
    -- =====================================================

    SELECT
        COUNT(*),
        COALESCE(MAX(coverage_percentage), 0),
        COALESCE(MAX(coverage_limit), 0)
    INTO
        v_treatment_covered,
        v_coverage_percentage,
        v_treatment_limit
    FROM PlanTreatment
    WHERE plan_id = v_plan_id
      AND treatment_id = v_treatment_id;


    -- =====================================================
    -- CALCULATE ELIGIBLE AMOUNT
    -- =====================================================

    IF v_treatment_covered = 1 THEN

        SET v_eligible_amount =
            LEAST(
                v_claim_amount * v_coverage_percentage / 100,
                v_treatment_limit
            );

    ELSE

        SET v_eligible_amount = 0;

    END IF;


    -- =====================================================
    -- CALCULATE REMAINING POLICY COVERAGE
    -- =====================================================

    SELECT
        v_sum_insured -
        COALESCE(
            (
                SELECT SUM(s.settlement_amount)
                FROM Settlement s
                JOIN Claim c2
                    ON s.claim_id = c2.claim_id
                WHERE c2.policy_id = v_policy_id
                  AND s.settlement_status = 'Processed'
                  AND c2.claim_id <> p_claim_id
            ),
            0
        )
    INTO v_remaining_coverage;


    -- =====================================================
    -- DUPLICATE CLAIM CHECK
    -- =====================================================

    SELECT COUNT(*)
    INTO v_duplicate_count
    FROM Claim c
    WHERE c.claim_id <> p_claim_id
      AND c.policy_id = v_policy_id
      AND c.hospital_id = v_hospital_id
      AND c.treatment_id = v_treatment_id
      AND c.admission_date = v_admission_date
      AND c.discharge_date = v_discharge_date;


    -- =====================================================
    -- DOCUMENT VERIFICATION CHECK
    -- =====================================================

    SELECT COUNT(*)
    INTO v_document_count
    FROM ClaimDocument
    WHERE claim_id = p_claim_id;


    SELECT COUNT(*)
    INTO v_unverified_documents
    FROM ClaimDocument
    WHERE claim_id = p_claim_id
      AND verification_status <> 'Verified';


    -- =====================================================
    -- FINAL DECISION LOGIC
    -- =====================================================

    /*
       PRIORITY:

       1. Invalid policy        -> REJECT
       2. Treatment not covered -> REJECT
       3. Treatment outside policy period -> REJECT
       4. Insufficient coverage -> REJECT
       5. Duplicate claim      -> MANUAL
       6. Documents incomplete -> MANUAL
       7. Otherwise             -> APPROVE
    */


    IF v_policy_status <> 'Active'
       OR v_admission_date < v_policy_start
       OR v_discharge_date > v_policy_end THEN

        SET v_decision = 'Reject';
        SET v_risk_level = 'High';


    ELSEIF v_treatment_covered = 0 THEN

        SET v_decision = 'Reject';
        SET v_risk_level = 'High';


    ELSEIF v_remaining_coverage < v_eligible_amount THEN

        SET v_decision = 'Reject';
        SET v_risk_level = 'High';


    ELSEIF v_duplicate_count > 0 THEN

        SET v_decision = 'Manual Verification';
        SET v_risk_level = 'High';


    ELSEIF v_document_count = 0
           OR v_unverified_documents > 0 THEN

        SET v_decision = 'Manual Verification';
        SET v_risk_level = 'Medium';


    ELSE

        SET v_decision = 'Approve';
        SET v_risk_level = 'Low';

    END IF;


    -- =====================================================
    -- RETURN EXPLAINABLE RESULT
    -- =====================================================

    SELECT

        p_claim_id AS claim_id,

        v_policy_id AS policy_id,

        v_plan_id AS plan_id,

        v_claim_amount AS claim_amount,

        v_eligible_amount AS eligible_amount,

        v_remaining_coverage AS remaining_coverage,

        CASE
            WHEN v_policy_status = 'Active'
             AND v_admission_date >= v_policy_start
             AND v_discharge_date <= v_policy_end
            THEN 'PASS'
            ELSE 'FAIL'
        END AS policy_validity_check,

        CASE
            WHEN v_treatment_covered = 1
            THEN 'PASS'
            ELSE 'FAIL'
        END AS treatment_coverage_check,

        CASE
            WHEN v_admission_date >= v_policy_start
             AND v_discharge_date <= v_policy_end
            THEN 'PASS'
            ELSE 'FAIL'
        END AS treatment_date_check,

        CASE
            WHEN v_remaining_coverage >= v_eligible_amount
            THEN 'PASS'
            ELSE 'FAIL'
        END AS coverage_check,

        CASE
            WHEN v_duplicate_count = 0
            THEN 'PASS'
            ELSE 'WARNING'
        END AS duplicate_check,

        CASE
            WHEN v_document_count > 0
             AND v_unverified_documents = 0
            THEN 'PASS'
            ELSE 'WARNING'
        END AS document_check,

        v_duplicate_count AS similar_claims_found,

        v_unverified_documents AS unverified_documents,

        v_decision AS recommended_decision,

        v_risk_level AS risk_level,

        CASE

            WHEN v_policy_status <> 'Active'
              OR v_admission_date < v_policy_start
              OR v_discharge_date > v_policy_end
            THEN 'Policy is not valid for the treatment period'

            WHEN v_treatment_covered = 0
            THEN 'Treatment is not covered by the policy plan'

            WHEN v_remaining_coverage < v_eligible_amount
            THEN 'Insufficient remaining policy coverage'

            WHEN v_duplicate_count > 0
            THEN 'Possible duplicate claim detected; manual verification required'

            WHEN v_document_count = 0
              OR v_unverified_documents > 0
            THEN 'Claim documents are incomplete or not fully verified'

            ELSE 'All required checks passed'

        END AS decision_explanation;

END$$

DELIMITER ;


-- =========================================================
-- TEST THE DECISION SYSTEM
-- =========================================================


-- Test 1: Normal approved claim
CALL EvaluateClaim(1);


-- Test 2: Expired policy
CALL EvaluateClaim(2);


-- Test 3: Possible duplicate
CALL EvaluateClaim(3);


-- Test 4: High-value claim
CALL EvaluateClaim(4);


-- Test 5: Approved claim
CALL EvaluateClaim(5);


-- Test 6: Approved claim
CALL EvaluateClaim(6);


-- Test 7: Approved claim
CALL EvaluateClaim(7);


-- Test 8: Approved claim
CALL EvaluateClaim(8);


-- =========================================================
-- VIEW STORED PROCEDURE
-- =========================================================

SHOW CREATE PROCEDURE EvaluateClaim;