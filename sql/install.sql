-- Leave module database schema for FrontAccounting

-- Leave requests table
CREATE TABLE IF NOT EXISTS `fa_leave_requests` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `employee_id` INT(11) NOT NULL,
    `leave_type` ENUM('Annual','Sick','Personal','Maternity','Paternity','Bereavement','Unpaid','Other') NOT NULL DEFAULT 'Annual',
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `days` DECIMAL(3,1) NOT NULL DEFAULT 0,
    `status` ENUM('Pending','Approved','Rejected','Cancelled') NOT NULL DEFAULT 'Pending',
    `reason` TEXT,
    `approved_by` INT(11) DEFAULT NULL,
    `approved_at` DATETIME DEFAULT NULL,
    `created_by` INT(11) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `employee_id` (`employee_id`),
    KEY `status` (`status`),
    KEY `leave_type` (`leave_type`),
    KEY `dates` (`start_date`,`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave balances
CREATE TABLE IF NOT EXISTS `fa_leave_balances` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `employee_id` INT(11) NOT NULL,
    `year` YEAR NOT NULL,
    `leave_type` ENUM('Annual','Sick','Personal') NOT NULL DEFAULT 'Annual',
    `entitlement` DECIMAL(5,1) NOT NULL DEFAULT 0,
    `used` DECIMAL(5,1) NOT NULL DEFAULT 0,
    `carried_forward` DECIMAL(5,1) NOT NULL DEFAULT 0,
    `updated_at` DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `employee_year_type` (`employee_id`,`year`,`leave_type`),
    KEY `employee_id` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Leave calendar/holidays
CREATE TABLE IF NOT EXISTS `fa_leave_holidays` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `date` DATE NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `type` ENUM('Public','Company','Optional') NOT NULL DEFAULT 'Public',
    `active` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Module version
INSERT INTO `fa_modules` (`name`, `version`, `enabled`, `installed`) VALUES
('Leave', '1.0.0', 1, NOW())
ON DUPLICATE KEY UPDATE `version` = '1.0.0', `installed` = NOW();