-- =========================================================
-- HEALTH INSURANCE POLICY AND CLAIMS MANAGEMENT SYSTEM
-- Database: MySQL 8.0+
-- =========================================================

DROP DATABASE IF EXISTS HealthInsuranceDB;

CREATE DATABASE HealthInsuranceDB;

USE HealthInsuranceDB;


-- =========================================================
-- 1. CUSTOMER
-- =========================================================

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,

    CHECK (gender IN ('Male', 'Female', 'Other'))
) ENGINE=InnoDB;


-- =========================================================
-- 2. PLAN
-- =========================================================

CREATE TABLE Plan (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    coverage_limit DECIMAL(12,2) NOT NULL,
    premium_amount DECIMAL(10,2) NOT NULL,
    plan_status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CHECK (coverage_limit > 0),
    CHECK (premium_amount > 0),
    CHECK (plan_status IN ('Active', 'Inactive'))
) ENGINE=InnoDB;


-- =========================================================
-- 3. TREATMENT
-- =========================================================

CREATE TABLE Treatment (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    treatment_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    standard_cost DECIMAL(12,2) NOT NULL,

    CHECK (standard_cost > 0)
) ENGINE=InnoDB;


-- =========================================================
-- 4. HOSPITAL
-- =========================================================

CREATE TABLE Hospital (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    hospital_type VARCHAR(30) NOT NULL,

    CHECK (hospital_type IN ('Private', 'Government', 'Trust'))
) ENGINE=InnoDB;


-- =========================================================
-- 5. PLAN_TREATMENT
-- Many-to-many relationship between Plan and Treatment
-- =========================================================

CREATE TABLE PlanTreatment (
    plan_id INT NOT NULL,
    treatment_id INT NOT NULL,
    coverage_percentage DECIMAL(5,2) NOT NULL,
    coverage_limit DECIMAL(12,2) NOT NULL,

    PRIMARY KEY (plan_id, treatment_id),

    FOREIGN KEY (plan_id)
        REFERENCES Plan(plan_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (treatment_id)
        REFERENCES Treatment(treatment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (coverage_percentage > 0
           AND coverage_percentage <= 100),

    CHECK (coverage_limit > 0)
) ENGINE=InnoDB;


-- =========================================================
-- 6. POLICY
-- =========================================================

CREATE TABLE Policy (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    sum_insured DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',

    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (plan_id)
        REFERENCES Plan(plan_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (end_date > start_date),
    CHECK (sum_insured > 0),
    CHECK (status IN ('Active', 'Expired', 'Cancelled', 'Pending'))
) ENGINE=InnoDB;


-- =========================================================
-- 7. DEPENDENT
-- =========================================================

CREATE TABLE Dependent (
    dependent_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    dependent_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(30) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,

    FOREIGN KEY (policy_id)
        REFERENCES Policy(policy_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (gender IN ('Male', 'Female', 'Other'))
) ENGINE=InnoDB;


-- =========================================================
-- 8. PREMIUM
-- =========================================================

CREATE TABLE Premium (
    premium_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_id INT NOT NULL,
    due_date DATE NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Due',

    FOREIGN KEY (policy_id)
        REFERENCES Policy(policy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (amount_due > 0),
    CHECK (status IN ('Due', 'Paid', 'Overdue'))
) ENGINE=InnoDB;


-- =========================================================
-- 9. PAYMENT
-- =========================================================

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    premium_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(50) NOT NULL UNIQUE,

    FOREIGN KEY (premium_id)
        REFERENCES Premium(premium_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (amount_paid > 0),
    CHECK (
        payment_method IN
        ('Cash', 'Card', 'UPI', 'Bank Transfer')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 10. CLAIM
-- =========================================================

CREATE TABLE Claim (
    claim_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_number VARCHAR(20) NOT NULL UNIQUE,
    policy_id INT NOT NULL,
    hospital_id INT NOT NULL,
    treatment_id INT NOT NULL,
    claim_date DATE NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    FOREIGN KEY (policy_id)
        REFERENCES Policy(policy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (hospital_id)
        REFERENCES Hospital(hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (treatment_id)
        REFERENCES Treatment(treatment_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (claim_amount > 0),
    CHECK (discharge_date >= admission_date),

    CHECK (
        status IN
        ('Pending', 'Under Assessment', 'Approved',
         'Rejected', 'Manual Verification', 'Settled')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 11. CLAIM DOCUMENT
-- =========================================================

CREATE TABLE ClaimDocument (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    document_name VARCHAR(150) NOT NULL,
    submission_date DATE NOT NULL,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'Pending',

    FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (
        verification_status IN
        ('Pending', 'Verified', 'Rejected')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 12. ASSESSMENT
-- One assessment per claim
-- =========================================================

CREATE TABLE Assessment (
    assessment_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL UNIQUE,
    assessment_date DATE NOT NULL,
    eligible_amount DECIMAL(12,2) NOT NULL,
    assessment_status VARCHAR(30) NOT NULL,
    remarks VARCHAR(255),

    FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (eligible_amount >= 0),

    CHECK (
        assessment_status IN
        ('Pending', 'Completed', 'Requires Review')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 13. CLAIM DECISION
-- One final decision per claim
-- =========================================================

CREATE TABLE ClaimDecision (
    decision_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL UNIQUE,
    decision_date DATE NOT NULL,
    decision VARCHAR(30) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,

    FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (
        decision IN
        ('Approve', 'Manual Verification', 'Reject')
    ),

    CHECK (
        risk_level IN
        ('Low', 'Medium', 'High')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 14. DECISION CHECK
-- Stores individual explanations behind a decision
-- =========================================================

CREATE TABLE DecisionCheck (
    check_id INT AUTO_INCREMENT PRIMARY KEY,
    decision_id INT NOT NULL,
    check_type VARCHAR(50) NOT NULL,
    check_result VARCHAR(20) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    explanation VARCHAR(255) NOT NULL,

    FOREIGN KEY (decision_id)
        REFERENCES ClaimDecision(decision_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (
        check_result IN
        ('PASS', 'FAIL', 'WARNING')
    ),

    CHECK (
        severity IN
        ('None', 'Low', 'Medium', 'High')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 15. SETTLEMENT
-- One settlement per claim
-- =========================================================

CREATE TABLE Settlement (
    settlement_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL UNIQUE,
    settlement_date DATE NOT NULL,
    settlement_amount DECIMAL(12,2) NOT NULL,
    settlement_status VARCHAR(20) NOT NULL DEFAULT 'Processed',
    payment_reference VARCHAR(50) NOT NULL UNIQUE,

    FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (settlement_amount > 0),

    CHECK (
        settlement_status IN
        ('Pending', 'Processed', 'Failed')
    )
) ENGINE=InnoDB;


-- =========================================================
-- 16. APPEAL
-- =========================================================

CREATE TABLE Appeal (
    appeal_id INT AUTO_INCREMENT PRIMARY KEY,
    claim_id INT NOT NULL,
    appeal_date DATE NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    resolution_date DATE,
    remarks VARCHAR(255),

    FOREIGN KEY (claim_id)
        REFERENCES Claim(claim_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (
        status IN
        ('Pending', 'Under Review', 'Accepted', 'Rejected')
    ),

    CHECK (
        resolution_date IS NULL
        OR resolution_date >= appeal_date
    )
) ENGINE=InnoDB;


-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_policy_customer
ON Policy(customer_id);

CREATE INDEX idx_policy_plan
ON Policy(plan_id);

CREATE INDEX idx_policy_status
ON Policy(status);

CREATE INDEX idx_premium_policy
ON Premium(policy_id);

CREATE INDEX idx_premium_status
ON Premium(status);

CREATE INDEX idx_claim_policy
ON Claim(policy_id);

CREATE INDEX idx_claim_hospital
ON Claim(hospital_id);

CREATE INDEX idx_claim_treatment
ON Claim(treatment_id);

CREATE INDEX idx_claim_status
ON Claim(status);

CREATE INDEX idx_claim_date
ON Claim(claim_date);

CREATE INDEX idx_document_claim
ON ClaimDocument(claim_id);

CREATE INDEX idx_decisioncheck_decision
ON DecisionCheck(decision_id);

CREATE INDEX idx_appeal_claim
ON Appeal(claim_id);

CREATE INDEX idx_appeal_status
ON Appeal(status);


-- =========================================================
-- END OF DATABASE STRUCTURE
-- =========================================================