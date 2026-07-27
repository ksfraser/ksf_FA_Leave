-- ============================================================================
-- ksf_FA_Leave Module Installation SQL
-- ============================================================================
-- Leave management: requests, approvals, balances, banks, and calendar.
-- Uses 0_ prefix for FA db_import(). Links to HRM via person_id.
-- ============================================================================

-- Leave types lookup (master list, managed via Leave Types admin page)
CREATE TABLE IF NOT EXISTS `0_leave_types` (
    `leave_type_id` INT(11) NOT NULL AUTO_INCREMENT,
    `type_code` VARCHAR(20) NOT NULL,
    `type_name` VARCHAR(100) NOT NULL,
    `default_days` DECIMAL(5,1) DEFAULT 0 COMMENT 'Default annual allocation',
    `is_paid` TINYINT(1) DEFAULT 1,
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`leave_type_id`),
    UNIQUE KEY `idx_code` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave requests
CREATE TABLE IF NOT EXISTS `0_leave_requests` (
    `request_id` INT(11) NOT NULL AUTO_INCREMENT,
    `person_id` INT(11) NOT NULL COMMENT 'FK to 0_crm_persons.id',
    `employment_id` INT(11) DEFAULT NULL COMMENT 'FK to 0_hrm_contacts_employment.employment_id',
    `leave_type_id` INT(11) NOT NULL COMMENT 'FK to 0_leave_types.leave_type_id',
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `days` DECIMAL(5,1) NOT NULL DEFAULT 0,
    `reason` TEXT,
    `status` VARCHAR(20) DEFAULT 'Pending' COMMENT 'Pending|Approved|Rejected|Cancelled',
    `approved_by_person_id` INT(11) DEFAULT NULL,
    `approved_at` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`request_id`),
    KEY `idx_person` (`person_id`),
    KEY `idx_employment` (`employment_id`),
    KEY `idx_type` (`leave_type_id`),
    KEY `idx_status` (`status`),
    KEY `idx_dates` (`start_date`, `end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave balances (current balance per leave type per person per year)
CREATE TABLE IF NOT EXISTS `0_leave_balances` (
    `balance_id` INT(11) NOT NULL AUTO_INCREMENT,
    `person_id` INT(11) NOT NULL COMMENT 'FK to 0_crm_persons.id',
    `employment_id` INT(11) DEFAULT NULL COMMENT 'FK to 0_hrm_contacts_employment.employment_id',
    `leave_type_id` INT(11) NOT NULL COMMENT 'FK to 0_leave_types.leave_type_id',
    `year` INT(4) NOT NULL,
    `entitlement` DECIMAL(5,1) DEFAULT 0 COMMENT 'Annual allocation',
    `used` DECIMAL(5,1) DEFAULT 0 COMMENT 'Total used this year',
    `balance` DECIMAL(5,1) DEFAULT 0 COMMENT 'Current balance (entitlement - used)',
    `carry_over` DECIMAL(5,1) DEFAULT 0 COMMENT 'Brought forward from prior year',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`balance_id`),
    UNIQUE KEY `idx_person_type_year` (`person_id`, `leave_type_id`, `year`),
    KEY `idx_employment` (`employment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave bank configuration (per leave type: how it accrues, what unit, rules)
CREATE TABLE IF NOT EXISTS `0_leave_bank_config` (
    `config_id` INT(11) NOT NULL AUTO_INCREMENT,
    `leave_type_id` INT(11) NOT NULL COMMENT 'FK to 0_leave_types',
    `accrual_unit` VARCHAR(20) NOT NULL DEFAULT 'Days' COMMENT 'Days|Hours|Dollars',
    `annual_accrual` DECIMAL(10,2) DEFAULT 0 COMMENT 'Max accrual per year',
    `accrual_rate` DECIMAL(10,4) DEFAULT 0 COMMENT 'Per period accrual amount',
    `max_balance` DECIMAL(10,2) DEFAULT 0 COMMENT 'Cap on bank (0=unlimited)',
    `allow_negative` TINYINT(1) DEFAULT 0 COMMENT 'Allow bank to go below zero',
    `negative_cap` DECIMAL(10,2) DEFAULT 0 COMMENT 'Max negative balance if allowed',
    `on_depletion` VARCHAR(30) DEFAULT 'ShowZeroRate' COMMENT 'ShowZeroRate|ConvertToLWP|Error',
    `zero_on_termination` TINYINT(1) DEFAULT 1 COMMENT 'Zero bank on final pay',
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`config_id`),
    UNIQUE KEY `idx_leave_type` (`leave_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee leave banks (current balance per leave type per year)
CREATE TABLE IF NOT EXISTS `0_leave_banks` (
    `bank_id` INT(11) NOT NULL AUTO_INCREMENT,
    `employment_id` INT(11) NOT NULL COMMENT 'FK to 0_hrm_contacts_employment.employment_id',
    `leave_type_id` INT(11) NOT NULL COMMENT 'FK to 0_leave_types',
    `year` INT(4) NOT NULL,
    `accrued` DECIMAL(10,2) DEFAULT 0 COMMENT 'Total accrued this year',
    `used` DECIMAL(10,2) DEFAULT 0 COMMENT 'Total used this year',
    `balance` DECIMAL(10,2) DEFAULT 0 COMMENT 'Current balance (accrued - used)',
    `carry_over` DECIMAL(10,2) DEFAULT 0 COMMENT 'Brought forward from prior year',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`bank_id`),
    UNIQUE KEY `idx_emp_type_year` (`employment_id`, `leave_type_id`, `year`),
    KEY `idx_employment` (`employment_id`),
    KEY `idx_type` (`leave_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave transactions (accruals, usage, adjustments - audit trail)
CREATE TABLE IF NOT EXISTS `0_leave_transactions` (
    `transaction_id` INT(11) NOT NULL AUTO_INCREMENT,
    `employment_id` INT(11) NOT NULL COMMENT 'FK to 0_hrm_contacts_employment.employment_id',
    `leave_type_id` INT(11) NOT NULL COMMENT 'FK to 0_leave_types',
    `transaction_type` VARCHAR(20) NOT NULL COMMENT 'Accrual|Usage|Adjustment|CarryOver|Payout',
    `amount` DECIMAL(10,2) NOT NULL COMMENT 'Positive=credit, Negative=debit',
    `balance_after` DECIMAL(10,2) DEFAULT 0,
    `reference_type` VARCHAR(30) DEFAULT NULL COMMENT 'Payroll|LeaveRequest|Manual|Termination',
    `reference_id` INT(11) DEFAULT NULL COMMENT 'FK to source record',
    `notes` VARCHAR(255) DEFAULT NULL,
    `created_by_person_id` INT(11) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`transaction_id`),
    KEY `idx_employment` (`employment_id`),
    KEY `idx_type` (`leave_type_id`),
    KEY `idx_trans_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave calendar/holidays
CREATE TABLE IF NOT EXISTS `0_leave_holidays` (
    `holiday_id` INT(11) NOT NULL AUTO_INCREMENT,
    `holiday_date` DATE NOT NULL,
    `holiday_name` VARCHAR(255) NOT NULL,
    `holiday_type` VARCHAR(20) DEFAULT 'Public' COMMENT 'Public|Company|Optional',
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`holiday_id`),
    UNIQUE KEY `idx_date` (`holiday_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave approval matrix (who approves for whom)
CREATE TABLE IF NOT EXISTS `0_leave_approval_matrix` (
    `matrix_id` INT(11) NOT NULL AUTO_INCREMENT,
    `employee_person_id` INT(11) NOT NULL COMMENT 'FK to 0_crm_persons.id (requester)',
    `approver_person_id` INT(11) NOT NULL COMMENT 'FK to 0_crm_persons.id (approver)',
    `leave_type_id` INT(11) DEFAULT NULL COMMENT 'NULL = all types',
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`matrix_id`),
    KEY `idx_employee` (`employee_person_id`),
    KEY `idx_approver` (`approver_person_id`),
    KEY `idx_type` (`leave_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Module settings
CREATE TABLE IF NOT EXISTS `0_leave_settings` (
    `setting_id` INT(11) NOT NULL AUTO_INCREMENT,
    `setting_key` VARCHAR(50) NOT NULL,
    `setting_value` TEXT,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`setting_id`),
    UNIQUE KEY `idx_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Default leave types
INSERT IGNORE INTO `0_leave_types` (leave_type_id, type_code, type_name, default_days, is_paid) VALUES
(1, 'ANNUAL', 'Annual Leave', 20, 1),
(2, 'SICK', 'Sick Leave', 10, 1),
(3, 'PERSONAL', 'Personal Leave', 5, 1),
(4, 'MATERNITY', 'Maternity Leave', 90, 1),
(5, 'PATERNITY', 'Paternity Leave', 5, 1),
(6, 'BEREAVEMENT', 'Bereavement Leave', 3, 1),
(7, 'UNPAID', 'Unpaid Leave', 0, 0),
(8, 'OTHER', 'Other Leave', 0, 1);

-- Default leave bank configs
INSERT IGNORE INTO `0_leave_bank_config` (config_id, leave_type_id, accrual_unit, annual_accrual, accrual_rate, max_balance, allow_negative, negative_cap, on_depletion, zero_on_termination) VALUES
(1, 1, 'Days', 20.00, 1.6667, 40.00, 0, 0.00, 'ShowZeroRate', 1),
(2, 2, 'Days', 10.00, 0.8333, 20.00, 0, 0.00, 'ShowZeroRate', 1),
(3, 3, 'Days', 5.00, 0.4167, 10.00, 0, 0.00, 'ShowZeroRate', 1),
(4, 4, 'Days', 90.00, 0.0000, 90.00, 0, 0.00, 'ShowZeroRate', 1),
(5, 5, 'Days', 5.00, 0.4167, 10.00, 0, 0.00, 'ShowZeroRate', 1);
