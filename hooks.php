<?php
/**
 * FA_Leave Module Hooks for FrontAccounting
 */

define('SS_LEAVE', 123 << 8);

class hooks_fa_leave extends hooks {

    private function ensure_composer_dependencies(): void {
        $module_dir = dirname(__FILE__);
        $autoload_path = $module_dir . '/vendor/autoload.php';
        
        if (!file_exists($autoload_path)) {
            $composer_path = $module_dir . '/composer.json';
            if (file_exists($composer_path)) {
                chdir($module_dir);
                $output = [];
                $return_code = 0;
                exec('composer install --no-interaction --prefer-dist 2>&1', $output, $return_code);
                if ($return_code !== 0) {
                    error_log('KSF Module: composer install failed: ' . implode("\n", $output));
                }
            }
        }
    }
    var $module_name = 'fa_leave';

    private function ensure_composer_dependencies(): void {
        $module_dir = dirname(__FILE__);
        $autoload_path = $module_dir . '/vendor/autoload.php';
        
        if (!file_exists($autoload_path)) {
            $composer_path = $module_dir . '/composer.json';
            if (file_exists($composer_path)) {
                chdir($module_dir);
                $output = [];
                $return_code = 0;
                exec('composer install --no-interaction --prefer-dist 2>&1', $output, $return_code);
                if ($return_code !== 0) {
                    error_log('KSF Module: composer install failed: ' . implode("\n", $output));
                }
            }
        }
    }
    var $version = '1.0.0';

    private function ensure_composer_dependencies(): void {
        $module_dir = dirname(__FILE__);
        $autoload_path = $module_dir . '/vendor/autoload.php';
        
        if (!file_exists($autoload_path)) {
            $composer_path = $module_dir . '/composer.json';
            if (file_exists($composer_path)) {
                chdir($module_dir);
                $output = [];
                $return_code = 0;
                exec('composer install --no-interaction --prefer-dist 2>&1', $output, $return_code);
                if ($return_code !== 0) {
                    error_log('KSF Module: composer install failed: ' . implode("\n", $output));
                }
            }
        }
    }

    function install_options($app) {
        global $path_to_root;

        switch($app->id) {
            case 'HR':
                $app->add_lapp_function(0, _("Leave Requests"),
                    $path_to_root."/modules/".$this->module_name."/requests.php", 'SA_LEAVEVIEW', MENU_ENTRY);
                $app->add_lapp_function(1, _("Apply for Leave"),
                    $path_to_root."/modules/".$this->module_name."/apply.php", 'SA_LEAVECREATE', MENU_ENTRY);
                $app->add_lapp_function(2, _("Leave Balances"),
                    $path_to_root."/modules/".$this->module_name."/balances.php", 'SA_LEAVEVIEW', MENU_INQUIRY);
                $app->add_rapp_function(3, _("Leave Configuration"),
                    $path_to_root."/modules/".$this->module_name."/configure.php", 'SA_LEAVECONFIGURE', MENU_MAINTENANCE);
                break;
        }
    }

    function install_access() {
        $security_sections[SS_LEAVE] = _("Leave Management");
        $security_areas['SA_LEAVEVIEW'] = array(SS_LEAVE | 1, _("View Leave Requests"));
        $security_areas['SA_LEAVECREATE'] = array(SS_LEAVE | 2, _("Create Leave Requests"));
        $security_areas['SA_LEAVEAPPROVE'] = array(SS_LEAVE | 3, _("Approve/Reject Leave"));
        $security_areas['SA_LEAVECONFIGURE'] = array(SS_LEAVE | 4, _("Configure Leave Settings"));
        return array($security_areas, $security_sections);
    }

    function activate_extension($company, $check_only=true) {
        $updates = array('sql/update.sql' => array($this->module_name));
        $ok = $this->update_databases($company, $updates, $check_only);
        if ($check_only || !$ok) {
            return $ok;
        }
        $this->ensure_leave_schema();
        return $ok;
    }

    private function table_exists($table) {
        $sql = "SHOW TABLES LIKE " . db_escape($table);
        $res = db_query($sql, 'Failed checking table existence');
        return db_num_rows($res) > 0;
    }

    private function ensure_leave_schema() {
        $tables = array(
            TB_PREF . "fa_leave_requests" => "
                CREATE TABLE IF NOT EXISTS `" . TB_PREF . "fa_leave_requests` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `employee_id` VARCHAR(100) NOT NULL,
                    `leave_type` VARCHAR(50) DEFAULT 'Vacation',
                    `start_date` DATE NOT NULL,
                    `end_date` DATE NOT NULL,
                    `days_requested` DECIMAL(5,2) DEFAULT 0,
                    `reason` TEXT,
                    `status` VARCHAR(20) DEFAULT 'Pending',
                    `approved_by` VARCHAR(100) DEFAULT NULL,
                    `approved_at` DATETIME DEFAULT NULL,
                    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (`id`),
                    KEY `idx_employee` (`employee_id`),
                    KEY `idx_status` (`status`),
                    KEY `idx_dates` (`start_date`, `end_date`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

            TB_PREF . "fa_leave_balances" => "
                CREATE TABLE IF NOT EXISTS `" . TB_PREF . "fa_leave_balances` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `employee_id` VARCHAR(100) NOT NULL,
                    `leave_type` VARCHAR(50) DEFAULT 'Vacation',
                    `allocated_days` DECIMAL(5,2) DEFAULT 0,
                    `used_days` DECIMAL(5,2) DEFAULT 0,
                    `carried_over` DECIMAL(5,2) DEFAULT 0,
                    `year` INT(11) NOT NULL,
                    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (`id`),
                    UNIQUE KEY `idx_emp_type_year` (`employee_id`, `leave_type`, `year`),
                    KEY `idx_year` (`year`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

            TB_PREF . "fa_leave_holidays" => "
                CREATE TABLE IF NOT EXISTS `" . TB_PREF . "fa_leave_holidays` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `holiday_name` VARCHAR(100) NOT NULL,
                    `holiday_date` DATE NOT NULL,
                    `year` INT(11) NOT NULL,
                    `is_recurring` TINYINT(1) DEFAULT 0,
                    PRIMARY KEY (`id`),
                    KEY `idx_date` (`holiday_date`),
                    KEY `idx_year` (`year`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
        );

        foreach ($tables as $table_name => $sql) {
            db_query($sql, "Could not create Leave table: $table_name");
        }
    }

    function db_prevoid($trans_type, $trans_no) {
        // Handle voiding if needed
    }
}
?>
