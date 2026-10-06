USE healthinsurancedb;

-- =========================================================
-- TEST 1: CHECK NUMBER OF RECORDS IN EVERY TABLE
-- =========================================================

SELECT 'Customer' AS TableName, COUNT(*) AS RecordCount FROM Customer
UNION ALL
SELECT 'Plan', COUNT(*) FROM Plan
UNION ALL
SELECT 'Treatment', COUNT(*) FROM Treatment
UNION ALL
SELECT 'PlanTreatment', COUNT(*) FROM PlanTreatment
UNION ALL
SELECT 'Policy', COUNT(*) FROM Policy
UNION ALL
SELECT 'Dependent', COUNT(*) FROM Dependent
UNION ALL
SELECT 'Premium', COUNT(*) FROM Premium
UNION ALL
SELECT 'Payment', COUNT(*) FROM Payment
UNION ALL
SELECT 'Hospital', COUNT(*) FROM Hospital
UNION ALL
SELECT 'Claim', COUNT(*) FROM Claim
UNION ALL
SELECT 'ClaimDocument', COUNT(*) FROM ClaimDocument
UNION ALL
SELECT 'Assessment', COUNT(*) FROM Assessment
UNION ALL
SELECT 'ClaimDecision', COUNT(*) FROM ClaimDecision
UNION ALL
SELECT 'DecisionCheck', COUNT(*) FROM DecisionCheck
UNION ALL
SELECT 'Settlement', COUNT(*) FROM Settlement
UNION ALL
SELECT 'Appeal', COUNT(*) FROM Appeal;


-- =========================================================
-- TEST 2: PRIMARY KEY / RECORD RETRIEVAL
-- =========================================================

SELECT *
FROM Customer
WHERE customer_id = 1;


-- =========================================================
-- TEST 3: UNIQUE POLICY NUMBER
-- =========================================================

SELECT
    policy_number,
    COUNT(*) AS occurrences
FROM Policy
GROUP BY policy_number
HAVING COUNT(*) > 1;


-- Expected result: EMPTY


-- =========================================================
-- TEST 4: UNIQUE CLAIM NUMBER
-- =========================================================

SELECT
    claim_number,
    COUNT(*) AS occurrences
FROM Claim
GROUP BY claim_number
HAVING COUNT(*) > 1;


-- Expected result: EMPTY


-- =========================================================
-- TEST 5: ACTIVE POLICY CHECK
-- =========================================================

SELECT
    policy_number,
    status,
    start_date,
    end_date
FROM Policy
WHERE status = 'Active';


-- =========================================================
-- TEST 6: EXPIRED POLICY CHECK
-- =========================================================

SELECT
    policy_number,
    status,
    end_date
FROM Policy
WHERE status = 'Expired';


-- =========================================================
-- TEST 7: FOREIGN KEY RELATIONSHIP
-- CLAIM -> POLICY
-- =========================================================

SELECT
    cl.claim_number,
    p.policy_number,
    c.customer_name
FROM Claim cl
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id;


-- =========================================================
-- TEST 8: TREATMENT COVERAGE
-- =========================================================

SELECT
    p.policy_number,
    pl.plan_name,
    t.treatment_name,
    pt.coverage_percentage,
    pt.coverage_limit
FROM Policy p
JOIN Plan pl
    ON p.plan_id = pl.plan_id
JOIN PlanTreatment pt
    ON pl.plan_id = pt.plan_id
JOIN Treatment t
    ON pt.treatment_id = t.treatment_id
ORDER BY p.policy_number;


-- =========================================================
-- TEST 9: CLAIM DOCUMENT VERIFICATION
-- =========================================================

SELECT
    cl.claim_number,
    cd.document_type,
    cd.verification_status
FROM Claim cl
JOIN ClaimDocument cd
    ON cl.claim_id = cd.claim_id
ORDER BY cl.claim_number;


-- =========================================================
-- TEST 10: CLAIM DECISION CHECK
-- =========================================================

SELECT
    cl.claim_number,
    cd.decision,
    cd.risk_level
FROM Claim cl
JOIN ClaimDecision cd
    ON cl.claim_id = cd.claim_id
ORDER BY cl.claim_number;


-- =========================================================
-- TEST 11: EXPLAINABLE DECISION CHECKS
-- =========================================================

SELECT
    cl.claim_number,
    cd.decision,
    dc.check_type,
    dc.check_result,
    dc.severity,
    dc.explanation
FROM Claim cl
JOIN ClaimDecision cd
    ON cl.claim_id = cd.claim_id
JOIN DecisionCheck dc
    ON cd.decision_id = dc.decision_id
WHERE dc.check_result IN ('FAIL', 'WARNING')
ORDER BY cl.claim_number;


-- =========================================================
-- TEST 12: SETTLEMENT ONLY FOR CLAIMS
-- =========================================================

SELECT
    s.settlement_id,
    cl.claim_number,
    cl.status,
    s.settlement_amount,
    s.settlement_status
FROM Settlement s
JOIN Claim cl
    ON s.claim_id = cl.claim_id;


-- =========================================================
-- TEST 13: APPEAL RECORDS
-- =========================================================

SELECT
    a.appeal_id,
    cl.claim_number,
    a.status,
    a.reason
FROM Appeal a
JOIN Claim cl
    ON a.claim_id = cl.claim_id
ORDER BY a.appeal_date;


-- =========================================================
-- TEST 14: APPROVAL RATE
-- =========================================================

SELECT
    COUNT(*) AS total_decisions,
    SUM(decision = 'Approve') AS approved,
    SUM(decision = 'Reject') AS rejected,
    SUM(decision = 'Manual Verification') AS manual_verification,
    ROUND(
        100 * SUM(decision = 'Approve') / COUNT(*),
        2
    ) AS approval_percentage
FROM ClaimDecision;


-- =========================================================
-- TEST 15: DUPLICATE CLAIM DETECTION
-- =========================================================

SELECT
    c1.claim_number AS claim_1,
    c2.claim_number AS claim_2,
    c1.policy_id,
    c1.hospital_id,
    c1.treatment_id,
    c1.admission_date,
    c1.discharge_date
FROM Claim c1
JOIN Claim c2
    ON c1.policy_id = c2.policy_id
    AND c1.hospital_id = c2.hospital_id
    AND c1.treatment_id = c2.treatment_id
    AND c1.admission_date = c2.admission_date
    AND c1.discharge_date = c2.discharge_date
    AND c1.claim_id < c2.claim_id;


-- =========================================================
-- TEST 16: STORED PROCEDURE
-- =========================================================

CALL EvaluateClaim(1);

CALL EvaluateClaim(2);

CALL EvaluateClaim(3);


-- =========================================================
-- TEST 17: ACTIVE POLICY VIEW
-- =========================================================

SELECT *
FROM ActivePolicyReport;


-- =========================================================
-- TEST 18: PENDING CLAIM VIEW
-- =========================================================

SELECT *
FROM PendingClaimReport;

USE healthinsurancedb;

SELECT * FROM Customer;

SELECT * FROM Claim;

SELECT
    cl.claim_number,
    c.customer_name,
    p.policy_number,
    h.hospital_name,
    t.treatment_name,
    cl.claim_amount,
    cl.status
FROM Claim cl
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Hospital h
    ON cl.hospital_id = h.hospital_id
JOIN Treatment t
    ON cl.treatment_id = t.treatment_id;
    
    CALL EvaluateClaim(3);
    
    SELECT
    COUNT(*) AS total_decisions,
    SUM(decision = 'Approve') AS approved,
    SUM(decision = 'Reject') AS rejected,
    SUM(decision = 'Manual Verification') AS manual_verification,
    ROUND(
        100 * SUM(decision = 'Approve') / COUNT(*),
        2
    ) AS approval_percentage
FROM ClaimDecision;

SELECT
    h.hospital_name,
    h.city,
    COUNT(cl.claim_id) AS total_claims,
    COALESCE(SUM(cl.claim_amount), 0) AS total_claim_amount,
    COALESCE(AVG(cl.claim_amount), 0) AS average_claim_amount
FROM Hospital h
LEFT JOIN Claim cl
    ON h.hospital_id = cl.hospital_id
GROUP BY
    h.hospital_id,
    h.hospital_name,
    h.city
ORDER BY total_claims DESC;

CALL EvaluateClaim(3);