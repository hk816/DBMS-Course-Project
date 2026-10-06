USE healthinsurancedb;

START TRANSACTION;

-- =========================================================
-- 1. CUSTOMER
-- =========================================================

INSERT INTO Customer
(customer_name, date_of_birth, gender, phone, email, address)
VALUES
('Rahul Sharma', '1995-04-12', 'Male', '9876500001', 'rahul.sharma@email.com', 'Hyderabad'),
('Ananya Reddy', '1998-08-25', 'Female', '9876500002', 'ananya.reddy@email.com', 'Hyderabad'),
('Vikram Patel', '1987-02-18', 'Male', '9876500003', 'vikram.patel@email.com', 'Bangalore'),
('Sneha Rao', '1992-11-05', 'Female', '9876500004', 'sneha.rao@email.com', 'Chennai'),
('Arjun Mehta', '1975-06-30', 'Male', '9876500005', 'arjun.mehta@email.com', 'Mumbai'),
('Priya Nair', '1985-09-14', 'Female', '9876500006', 'priya.nair@email.com', 'Kochi');


-- =========================================================
-- 2. PLAN
-- =========================================================

INSERT INTO Plan
(plan_name, description, coverage_limit, premium_amount, plan_status)
VALUES
('Basic Health Plan', 'Basic hospitalization coverage', 300000.00, 18000.00, 'Active'),
('Family Health Plus', 'Family medical coverage', 500000.00, 30000.00, 'Active'),
('Senior Care Plan', 'Healthcare coverage for senior citizens', 700000.00, 42000.00, 'Active'),
('Premium Health Plan', 'Comprehensive health coverage', 1000000.00, 55000.00, 'Active'),
('Essential Care Plan', 'Affordable essential medical coverage', 400000.00, 22000.00, 'Active'),
('Legacy Health Plan', 'Previously offered health plan', 250000.00, 15000.00, 'Inactive');


-- =========================================================
-- 3. TREATMENT
-- =========================================================

INSERT INTO Treatment
(treatment_name, category, description, standard_cost)
VALUES
('Appendectomy', 'Surgery', 'Surgical removal of appendix', 80000.00),
('Cataract Surgery', 'Ophthalmology', 'Surgical treatment for cataract', 60000.00),
('Fracture Treatment', 'Orthopaedics', 'Treatment of bone fracture', 50000.00),
('Gallbladder Surgery', 'Surgery', 'Surgical removal of gallbladder', 120000.00),
('Pneumonia Hospitalization', 'General Medicine', 'Hospital treatment for pneumonia', 70000.00),
('Knee Replacement', 'Orthopaedics', 'Total knee replacement procedure', 250000.00);


-- =========================================================
-- 4. HOSPITAL
-- =========================================================

INSERT INTO Hospital
(hospital_name, address, city, phone, hospital_type)
VALUES
('Apollo Hospitals', 'Jubilee Hills', 'Hyderabad', '04040000001', 'Private'),
('Yashoda Hospitals', 'Somajiguda', 'Hyderabad', '04040000002', 'Private'),
('KIMS Hospitals', 'Secunderabad', 'Hyderabad', '04040000003', 'Private'),
('Government General Hospital', 'Park Town', 'Chennai', '04440000004', 'Government'),
('Sunshine Hospitals', 'Paradise', 'Hyderabad', '04040000005', 'Private'),
('Fortis Hospital', 'Bannerghatta Road', 'Bangalore', '08040000006', 'Private');


-- =========================================================
-- 5. PLAN_TREATMENT
-- =========================================================

INSERT INTO PlanTreatment
(plan_id, treatment_id, coverage_percentage, coverage_limit)
VALUES
(1, 1, 80.00, 100000.00),
(1, 3, 80.00, 75000.00),

(2, 1, 90.00, 150000.00),
(2, 2, 80.00, 100000.00),
(2, 3, 90.00, 100000.00),
(2, 5, 80.00, 100000.00),

(3, 2, 90.00, 150000.00),
(3, 3, 90.00, 100000.00),
(3, 6, 80.00, 300000.00),

(4, 1, 100.00, 200000.00),
(4, 2, 100.00, 200000.00),
(4, 3, 100.00, 150000.00),
(4, 4, 100.00, 250000.00),
(4, 5, 100.00, 150000.00),
(4, 6, 90.00, 400000.00),

(5, 1, 80.00, 100000.00),
(5, 3, 80.00, 80000.00),
(5, 5, 70.00, 80000.00);


-- =========================================================
-- 6. POLICY
-- =========================================================

INSERT INTO Policy
(policy_number, customer_id, plan_id, start_date, end_date, sum_insured, status)
VALUES
('POL1001', 1, 2, '2026-01-01', '2026-12-31', 500000.00, 'Active'),
('POL1002', 2, 4, '2026-02-01', '2027-01-31', 1000000.00, 'Active'),
('POL1003', 3, 1, '2025-01-01', '2025-12-31', 300000.00, 'Expired'),
('POL1004', 4, 5, '2026-03-01', '2027-02-28', 400000.00, 'Active'),
('POL1005', 5, 3, '2026-04-01', '2027-03-31', 700000.00, 'Active'),
('POL1006', 6, 2, '2026-05-01', '2027-04-30', 500000.00, 'Active');


-- =========================================================
-- 7. DEPENDENT
-- =========================================================

INSERT INTO Dependent
(policy_id, dependent_name, relationship, date_of_birth, gender)
VALUES
(1, 'Meera Sharma', 'Spouse', '1997-06-15', 'Female'),
(1, 'Aarav Sharma', 'Son', '2018-03-20', 'Male'),
(2, 'Riya Reddy', 'Daughter', '2015-09-10', 'Female'),
(2, 'Suresh Reddy', 'Father', '1960-12-05', 'Male'),
(4, 'Kavya Rao', 'Daughter', '2017-07-22', 'Female'),
(5, 'Neha Mehta', 'Spouse', '1978-04-11', 'Female');


-- =========================================================
-- 8. PREMIUM
-- =========================================================

INSERT INTO Premium
(policy_id, due_date, amount_due, status)
VALUES
(1, '2026-01-01', 30000.00, 'Paid'),
(1, '2026-07-01', 30000.00, 'Paid'),
(2, '2026-02-01', 55000.00, 'Paid'),
(3, '2025-07-01', 18000.00, 'Overdue'),
(4, '2026-03-01', 22000.00, 'Paid'),
(5, '2026-04-01', 42000.00, 'Due'),
(6, '2026-05-01', 30000.00, 'Overdue'),
(2, '2026-08-01', 55000.00, 'Paid');


-- =========================================================
-- 9. PAYMENT
-- =========================================================

INSERT INTO Payment
(premium_id, payment_date, amount_paid, payment_method, transaction_reference)
VALUES
(1, '2026-01-02', 30000.00, 'UPI', 'TXN10001'),
(2, '2026-07-02', 30000.00, 'Card', 'TXN10002'),
(3, '2026-02-02', 55000.00, 'Bank Transfer', 'TXN10003'),
(5, '2026-03-02', 22000.00, 'UPI', 'TXN10004'),
(8, '2026-08-02', 55000.00, 'Card', 'TXN10005');


-- =========================================================
-- 10. CLAIM
-- =========================================================

INSERT INTO Claim
(claim_number, policy_id, hospital_id, treatment_id,
 claim_date, admission_date, discharge_date,
 claim_amount, status)
VALUES

-- Normal approved claim
('CLM1001', 1, 1, 1,
 '2026-06-10', '2026-06-08', '2026-06-10',
 80000.00, 'Settled'),

-- Expired policy
('CLM1002', 3, 2, 1,
 '2026-01-15', '2026-01-12', '2026-01-15',
 75000.00, 'Rejected'),

-- Possible duplicate of CLM1001
('CLM1003', 1, 1, 1,
 '2026-06-11', '2026-06-08', '2026-06-10',
 80000.00, 'Manual Verification'),

-- Claim exceeds treatment coverage limit
('CLM1004', 2, 3, 6,
 '2026-08-05', '2026-08-02', '2026-08-05',
 450000.00, 'Rejected'),

-- Approved high-value claim
('CLM1005', 5, 6, 6,
 '2026-08-15', '2026-08-12', '2026-08-15',
 280000.00, 'Settled'),

-- Approved pneumonia claim
('CLM1006', 4, 5, 5,
 '2026-09-05', '2026-09-01', '2026-09-05',
 70000.00, 'Settled'),

-- Approved cataract claim
('CLM1007', 5, 2, 2,
 '2026-09-15', '2026-09-12', '2026-09-15',
 60000.00, 'Settled'),

-- Approved fracture claim
('CLM1008', 6, 3, 3,
 '2026-09-25', '2026-09-22', '2026-09-25',
 50000.00, 'Settled');


-- =========================================================
-- 11. CLAIM DOCUMENT
-- =========================================================

INSERT INTO ClaimDocument
(claim_id, document_type, document_name, submission_date, verification_status)
VALUES

(1, 'Medical Bill', 'CLM1001_Bill.pdf',
 '2026-06-11', 'Verified'),

(1, 'Discharge Summary', 'CLM1001_Discharge.pdf',
 '2026-06-11', 'Verified'),

(2, 'Medical Bill', 'CLM1002_Bill.pdf',
 '2026-01-16', 'Verified'),

(3, 'Medical Bill', 'CLM1003_Bill.pdf',
 '2026-06-12', 'Verified'),

(4, 'Medical Bill', 'CLM1004_Bill.pdf',
 '2026-08-06', 'Verified'),

(5, 'Medical Bill', 'CLM1005_Bill.pdf',
 '2026-08-16', 'Verified'),

(6, 'Medical Bill', 'CLM1006_Bill.pdf',
 '2026-09-06', 'Verified'),

(7, 'Medical Bill', 'CLM1007_Bill.pdf',
 '2026-09-16', 'Verified'),

(8, 'Medical Bill', 'CLM1008_Bill.pdf',
 '2026-09-26', 'Verified');


-- =========================================================
-- 12. ASSESSMENT
-- =========================================================

INSERT INTO Assessment
(claim_id, assessment_date, eligible_amount, assessment_status, remarks)
VALUES

(1, '2026-06-12', 72000.00, 'Completed',
 'Treatment covered at 90 percent'),

(2, '2026-01-17', 0.00, 'Completed',
 'Policy was expired on treatment date'),

(3, '2026-06-12', 72000.00, 'Requires Review',
 'Possible duplicate claim detected'),

(4, '2026-08-07', 400000.00, 'Completed',
 'Claim exceeds the treatment-specific reimbursement limit'),

(5, '2026-08-17', 224000.00, 'Completed',
 'Treatment covered at 80 percent'),

(6, '2026-09-07', 49000.00, 'Completed',
 'Treatment covered at 70 percent'),

(7, '2026-09-17', 54000.00, 'Completed',
 'Treatment covered at 90 percent'),

(8, '2026-09-27', 45000.00, 'Completed',
 'Treatment covered at 90 percent');


-- =========================================================
-- 13. CLAIM DECISION
-- =========================================================

INSERT INTO ClaimDecision
(claim_id, decision_date, decision, risk_level)
VALUES

(1, '2026-06-12', 'Approve', 'Low'),
(2, '2026-01-17', 'Reject', 'High'),
(3, '2026-06-12', 'Manual Verification', 'High'),
(4, '2026-08-07', 'Reject', 'High'),
(5, '2026-08-17', 'Approve', 'Low'),
(6, '2026-09-07', 'Approve', 'Low'),
(7, '2026-09-17', 'Approve', 'Low'),
(8, '2026-09-27', 'Approve', 'Low');


-- =========================================================
-- 14. DECISION CHECK
-- =========================================================

-- CLM1001 - APPROVED

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(1, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(1, 'Treatment Coverage', 'PASS', 'None',
 'Treatment is covered under the policy plan'),

(1, 'Coverage Availability', 'PASS', 'None',
 'Sufficient policy coverage is available'),

(1, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(1, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1002 - REJECTED: EXPIRED POLICY

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(2, 'Policy Validity', 'FAIL', 'High',
 'Policy had expired before the treatment date'),

(2, 'Treatment Coverage', 'PASS', 'None',
 'Treatment is covered under the selected plan'),

(2, 'Treatment Validity', 'FAIL', 'High',
 'Treatment occurred outside the policy validity period'),

(2, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(2, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1003 - MANUAL: POSSIBLE DUPLICATE

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(3, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(3, 'Treatment Coverage', 'PASS', 'None',
 'Treatment is covered under the policy plan'),

(3, 'Coverage Availability', 'PASS', 'None',
 'Sufficient coverage is available'),

(3, 'Duplicate Check', 'WARNING', 'High',
 'A similar claim exists for the same policy, hospital, treatment and admission period'),

(3, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1004 - REJECTED: EXCEEDS TREATMENT LIMIT

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(4, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(4, 'Treatment Coverage', 'PASS', 'None',
 'Knee Replacement is covered by the policy plan'),

(4, 'Coverage Availability', 'FAIL', 'High',
 'Claim amount exceeds the treatment-specific reimbursement limit'),

(4, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(4, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1005 - APPROVED

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(5, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(5, 'Treatment Coverage', 'PASS', 'None',
 'Knee Replacement is covered under the policy plan'),

(5, 'Coverage Availability', 'PASS', 'None',
 'Sufficient policy coverage is available'),

(5, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(5, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1006 - APPROVED

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(6, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(6, 'Treatment Coverage', 'PASS', 'None',
 'Pneumonia treatment is covered by the policy plan'),

(6, 'Coverage Availability', 'PASS', 'None',
 'Sufficient policy coverage is available'),

(6, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(6, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1007 - APPROVED

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(7, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(7, 'Treatment Coverage', 'PASS', 'None',
 'Cataract Surgery is covered by the policy plan'),

(7, 'Coverage Availability', 'PASS', 'None',
 'Sufficient policy coverage is available'),

(7, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(7, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- CLM1008 - APPROVED

INSERT INTO DecisionCheck
(decision_id, check_type, check_result, severity, explanation)
VALUES
(8, 'Policy Validity', 'PASS', 'None',
 'Policy was active on the treatment date'),

(8, 'Treatment Coverage', 'PASS', 'None',
 'Fracture Treatment is covered by the policy plan'),

(8, 'Coverage Availability', 'PASS', 'None',
 'Sufficient policy coverage is available'),

(8, 'Duplicate Check', 'PASS', 'None',
 'No duplicate claim was detected'),

(8, 'Document Check', 'PASS', 'None',
 'Required claim documents were verified');


-- =========================================================
-- 15. SETTLEMENT
-- =========================================================

INSERT INTO Settlement
(claim_id, settlement_date, settlement_amount, settlement_status, payment_reference)
VALUES
(1, '2026-06-15', 72000.00, 'Processed', 'SETTLE1001'),
(5, '2026-08-20', 224000.00, 'Processed', 'SETTLE1002'),
(6, '2026-09-10', 49000.00, 'Processed', 'SETTLE1003'),
(7, '2026-09-20', 54000.00, 'Processed', 'SETTLE1004'),
(8, '2026-09-30', 45000.00, 'Processed', 'SETTLE1005');


-- =========================================================
-- 16. APPEAL
-- =========================================================

INSERT INTO Appeal
(claim_id, appeal_date, reason, status, resolution_date, remarks)
VALUES

(2, '2026-01-25',
 'Customer disputes rejection and requests reconsideration',
 'Under Review', NULL,
 'Additional documents under review'),

(4, '2026-08-15',
 'Customer requests reconsideration of treatment reimbursement limit',
 'Pending', NULL,
 NULL),

(2, '2026-02-10',
 'Additional medical evidence submitted',
 'Rejected', '2026-02-15',
 'Policy validity condition was not satisfied'),

(1, '2026-06-20',
 'Customer requested clarification regarding settlement amount',
 'Accepted', '2026-06-22',
 'Settlement explanation provided'),

(5, '2026-08-25',
 'Customer requested detailed settlement statement',
 'Accepted', '2026-08-27',
 'Settlement statement provided');


COMMIT;