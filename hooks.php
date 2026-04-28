<?php
/**
 * Leave Module for FrontAccounting
 */

$module_id = 'Leave';
$module_version = '1.0.0';
$module_name = 'Leave Management';
$module_description = 'Employee leave request and tracking system';

$module_tables = [
    'fa_leave_requests',
    'fa_leave_balances',
    'fa_leave_holidays',
];

$module_capabilities = [
    'SA_LEAVEVIEW' => 'View Leave Requests',
    'SA_LEAVECREATE' => 'Create Leave Requests',
    'SA_LEAVEAPPROVE' => 'Approve/Reject Leave',
    'SA_LEAVECONFIGURE' => 'Configure Leave Settings',
];

function leave_install(): bool
{
    global $db, $db_multi_sql;
    $sql_file = dirname(__FILE__) . '/../sql/install.sql';
    if (!file_exists($sql_file)) return false;
    $sql = file_get_contents($sql_file);
    return $db_multi_sql($sql);
}

function leave_enable(): bool
{
    global $db;
    return $db->query("UPDATE " . TB_PREF . "modules SET enabled = 1 WHERE name = 'Leave'");
}

function leave_disable(): bool
{
    global $db;
    return $db->query("UPDATE " . TB_PREF . "modules SET enabled = 0 WHERE name = 'Leave'");
}

function leave_remove(): bool
{
    global $db, $db_multi_sql;
    $sql = "DROP TABLE IF EXISTS " . TB_PREF . "leave_holidays;
           DROP TABLE IF EXISTS " . TB_PREF . "leave_balances;
           DROP TABLE IF EXISTS " . TB_PREF . "leave_requests;
           DELETE FROM " . TB_PREF . "modules WHERE name = 'Leave';";
    return $db_multi_sql($sql);
}

add_module($module_name, $module_version, $module_description);