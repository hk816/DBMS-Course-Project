USE healthinsurancedb;


-- =========================================================
-- 1. VIEW ALL CUSTOMERS
-- =========================================================

SELECT *
FROM Customer;


-- =========================================================
-- 2. VIEW ACTIVE POLICIES
-- =========================================================

SELECT
    p.policy_number,
    c.customer_name,
    pl.plan_name,
    p.start_date,
    p.end_date,
    p.sum_insured,
    p.status
FROM Policy p
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Plan pl
    ON p.plan_id = pl.plan_id
WHERE p.status = 'Active';


-- =========================================================
-- 3. POLICY DETAILS WITH CUSTOMER AND PLAN
-- JOIN QUERY
-- =========================================================

SELECT
    p.policy_number,
    c.customer_name,
    c.phone,
    pl.plan_name,
    pl.coverage_limit,
    p.sum_insured,
    p.start_date,
    p.end_date,
    p.status
FROM Policy p
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Plan pl
    ON p.plan_id = pl.plan_id
ORDER BY p.policy_number;


-- =========================================================
-- 4. TREATMENTS COVERED BY EACH PLAN
-- MANY-TO-MANY JOIN
-- =========================================================

SELECT
    pl.plan_name,
    t.treatment_name,
    pt.coverage_percentage,
    pt.coverage_limit
FROM PlanTreatment pt
JOIN Plan pl
    ON pt.plan_id = pl.plan_id
JOIN Treatment t
    ON pt.treatment_id = t.treatment_id
ORDER BY pl.plan_name, t.treatment_name;


-- =========================================================
-- 5. PREMIUM DUES
-- REQUIRED REPORT
-- =========================================================

SELECT
    p.policy_number,
    c.customer_name,
    pr.premium_id,
    pr.due_date,
    pr.amount_due,
    pr.status
FROM Premium pr
JOIN Policy p
    ON pr.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
WHERE pr.status IN ('Due', 'Overdue')
ORDER BY pr.due_date;


-- =========================================================
-- 6. PREMIUM PAYMENT SUMMARY
-- AGGREGATE + LEFT JOIN
-- =========================================================

SELECT
    pr.premium_id,
    p.policy_number,
    pr.amount_due,
    COALESCE(SUM(pay.amount_paid), 0) AS amount_paid,
    pr.amount_due - COALESCE(SUM(pay.amount_paid), 0) AS outstanding_amount
FROM Premium pr
JOIN Policy p
    ON pr.policy_id = p.policy_id
LEFT JOIN Payment pay
    ON pr.premium_id = pay.premium_id
GROUP BY
    pr.premium_id,
    p.policy_number,
    pr.amount_due
ORDER BY pr.premium_id;


-- =========================================================
-- 7. CLAIM DETAILS
-- MULTIPLE TABLE JOIN
-- =========================================================

SELECT
    cl.claim_number,
    c.customer_name,
    p.policy_number,
    h.hospital_name,
    t.treatment_name,
    cl.claim_date,
    cl.admission_date,
    cl.discharge_date,
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
    ON cl.treatment_id = t.treatment_id
ORDER BY cl.claim_date;


-- =========================================================
-- 8. PENDING / MANUAL VERIFICATION CLAIMS
-- REQUIRED REPORT
-- =========================================================

SELECT
    cl.claim_number,
    c.customer_name,
    p.policy_number,
    t.treatment_name,
    cl.claim_amount,
    cl.status
FROM Claim cl
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Treatment t
    ON cl.treatment_id = t.treatment_id
WHERE cl.status IN ('Pending', 'Manual Verification')
ORDER BY cl.claim_date;


-- =========================================================
-- 9. CLAIMS BY STATUS
-- AGGREGATE QUERY
-- =========================================================

SELECT
    status,
    COUNT(*) AS number_of_claims,
    SUM(claim_amount) AS total_claim_amount,
    AVG(claim_amount) AS average_claim_amount
FROM Claim
GROUP BY status
ORDER BY number_of_claims DESC;


-- =========================================================
-- 10. HOSPITAL-WISE CLAIM REPORT
-- REQUIRED REPORT
-- =========================================================

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


-- =========================================================
-- 11. SETTLEMENT REPORT
-- REQUIRED REPORT
-- =========================================================

SELECT
    s.settlement_id,
    cl.claim_number,
    c.customer_name,
    s.settlement_date,
    s.settlement_amount,
    s.settlement_status,
    s.payment_reference
FROM Settlement s
JOIN Claim cl
    ON s.claim_id = cl.claim_id
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
ORDER BY s.settlement_date;


-- =========================================================
-- 12. TOTAL SETTLEMENT AMOUNT
-- AGGREGATE QUERY
-- =========================================================

SELECT
    COUNT(*) AS total_settlements,
    SUM(settlement_amount) AS total_settled_amount,
    AVG(settlement_amount) AS average_settlement_amount,
    MAX(settlement_amount) AS highest_settlement
FROM Settlement
WHERE settlement_status = 'Processed';


-- =========================================================
-- 13. CLAIM APPROVAL RATE
-- REQUIRED REPORT
-- =========================================================

SELECT
    COUNT(*) AS total_decisions,
    SUM(decision = 'Approve') AS approved_claims,
    SUM(decision = 'Reject') AS rejected_claims,
    SUM(decision = 'Manual Verification') AS manual_verification_claims,
    ROUND(
        100 * SUM(decision = 'Approve') / COUNT(*),
        2
    ) AS approval_rate_percentage
FROM ClaimDecision;


-- =========================================================
-- 14. CLAIM DECISION EXPLANATION
-- NOVELTY REPORT
-- =========================================================

SELECT
    cl.claim_number,
    cd.decision,
    cd.risk_level,
    dc.check_type,
    dc.check_result,
    dc.severity,
    dc.explanation
FROM Claim cl
JOIN ClaimDecision cd
    ON cl.claim_id = cd.claim_id
JOIN DecisionCheck dc
    ON cd.decision_id = dc.decision_id
ORDER BY cl.claim_number, dc.check_id;


-- =========================================================
-- 15. FAILED / WARNING DECISION CHECKS
-- NOVELTY REPORT
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
-- 16. DUPLICATE CLAIM DETECTION
-- NOVELTY QUERY
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
-- 17. CLAIMS ABOVE AVERAGE CLAIM AMOUNT
-- SUBQUERY
-- =========================================================

SELECT
    claim_number,
    claim_amount,
    status
FROM Claim
WHERE claim_amount >
(
    SELECT AVG(claim_amount)
    FROM Claim
)
ORDER BY claim_amount DESC;


-- =========================================================
-- 18. CUSTOMERS WITH HIGH-VALUE CLAIMS
-- SUBQUERY + JOIN
-- =========================================================

SELECT DISTINCT
    c.customer_name,
    p.policy_number
FROM Customer c
JOIN Policy p
    ON c.customer_id = p.customer_id
JOIN Claim cl
    ON p.policy_id = cl.policy_id
WHERE cl.claim_amount >
(
    SELECT AVG(claim_amount)
    FROM Claim
);


-- =========================================================
-- 19. PLAN-WISE CLAIM SUMMARY
-- AGGREGATE + JOIN
-- =========================================================

SELECT
    pl.plan_name,
    COUNT(cl.claim_id) AS total_claims,
    COALESCE(SUM(cl.claim_amount), 0) AS total_claim_amount,
    COALESCE(AVG(cl.claim_amount), 0) AS average_claim_amount
FROM Plan pl
LEFT JOIN Policy p
    ON pl.plan_id = p.plan_id
LEFT JOIN Claim cl
    ON p.policy_id = cl.policy_id
GROUP BY
    pl.plan_id,
    pl.plan_name
ORDER BY total_claims DESC;


-- =========================================================
-- 20. APPEAL REPORT
-- =========================================================

SELECT
    a.appeal_id,
    cl.claim_number,
    c.customer_name,
    a.appeal_date,
    a.reason,
    a.status,
    a.resolution_date,
    a.remarks
FROM Appeal a
JOIN Claim cl
    ON a.claim_id = cl.claim_id
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
ORDER BY a.appeal_date;


-- =========================================================
-- 21. CLAIM DOCUMENT VERIFICATION REPORT
-- =========================================================

SELECT
    cl.claim_number,
    c.customer_name,
    cd.document_type,
    cd.document_name,
    cd.submission_date,
    cd.verification_status
FROM ClaimDocument cd
JOIN Claim cl
    ON cd.claim_id = cl.claim_id
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
ORDER BY cl.claim_number;


-- =========================================================
-- 22. TREATMENT-WISE CLAIM SUMMARY
-- =========================================================

SELECT
    t.treatment_name,
    t.category,
    COUNT(cl.claim_id) AS total_claims,
    COALESCE(SUM(cl.claim_amount), 0) AS total_claim_amount
FROM Treatment t
LEFT JOIN Claim cl
    ON t.treatment_id = cl.treatment_id
GROUP BY
    t.treatment_id,
    t.treatment_name,
    t.category
ORDER BY total_claim_amount DESC;


-- =========================================================
-- 23. CREATE ACTIVE POLICY VIEW
-- =========================================================

CREATE OR REPLACE VIEW ActivePolicyReport AS
SELECT
    p.policy_number,
    c.customer_name,
    pl.plan_name,
    p.start_date,
    p.end_date,
    p.sum_insured,
    p.status
FROM Policy p
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Plan pl
    ON p.plan_id = pl.plan_id
WHERE p.status = 'Active';


-- Test the view
SELECT *
FROM ActivePolicyReport;


-- =========================================================
-- 24. CREATE PENDING CLAIM VIEW
-- =========================================================

CREATE OR REPLACE VIEW PendingClaimReport AS
SELECT
    cl.claim_number,
    c.customer_name,
    p.policy_number,
    t.treatment_name,
    h.hospital_name,
    cl.claim_amount,
    cl.status
FROM Claim cl
JOIN Policy p
    ON cl.policy_id = p.policy_id
JOIN Customer c
    ON p.customer_id = c.customer_id
JOIN Treatment t
    ON cl.treatment_id = t.treatment_id
JOIN Hospital h
    ON cl.hospital_id = h.hospital_id
WHERE cl.status IN ('Pending', 'Manual Verification');


-- Test the view
SELECT *
FROM PendingClaimReport;