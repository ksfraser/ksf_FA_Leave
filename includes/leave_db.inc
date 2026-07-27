<?php
/**
 * Leave Database Functions
 */

function create_leave_request(int $employee_id, string $leave_type, string $start_date, string $end_date, string $reason = ''): int
{
    global $db;
    $days = calculate_leave_days($start_date, $end_date);
    $sql = "INSERT INTO " . TB_PREF . "leave_requests 
        (employee_id, leave_type, start_date, end_date, days, reason, created_by)
        VALUES (" . $employee_id . ", " . $db->escape($leave_type) . ", " . $db->escape($start_date) . ", " . $db->escape($end_date) . ", " . $days . ", " . $db->escape($reason) . ", " . user_id() . ")";
    $db->query($sql);
    return $db->insert_id;
}

function get_leave_request(int $id): ?array
{
    global $db;
    $sql = "SELECT * FROM " . TB_PREF . "leave_requests WHERE id = " . $id;
    $result = $db->query($sql);
    if ($result && $db->num_rows($result) > 0) {
        return $db->fetch($result);
    }
    return null;
}

function update_leave_request(int $id, string $leave_type, string $start_date, string $end_date, string $reason = ''): bool
{
    global $db;
    $days = calculate_leave_days($start_date, $end_date);
    $sql = "UPDATE " . TB_PREF . "leave_requests SET leave_type = " . $db->escape($leave_type) . ", start_date = " . $db->escape($start_date) . ", end_date = " . $db->escape($end_date) . ", days = " . $days . ", reason = " . $db->escape($reason) . " WHERE id = " . $id;
    return $db->query($sql);
}

function approve_leave_request(int $id, int $approver_id): bool
{
    global $db;
    $sql = "UPDATE " . TB_PREF . "leave_requests SET status = 'Approved', approved_by = " . $approver_id . ", approved_at = NOW() WHERE id = " . $id;
    return $db->query($sql);
}

function reject_leave_request(int $id, int $approver_id): bool
{
    global $db;
    $sql = "UPDATE " . TB_PREF . "leave_requests SET status = 'Rejected', approved_by = " . $approver_id . ", approved_at = NOW() WHERE id = " . $id;
    return $db->query($sql);
}

function get_leave_requests(array $filters = []): ?object
{
    global $db;
    $sql = "SELECT r.*, e.name as employee_name FROM " . TB_PREF . "leave_requests r
        LEFT JOIN " . TB_PREF . "hr_employees e ON r.employee_id = e.id WHERE 1=1";
    
    if (!empty($filters['employee_id'])) {
        $sql .= " AND r.employee_id = " . $filters['employee_id'];
    }
    if (!empty($filters['status'])) {
        $sql .= " AND r.status = " . $db->escape($filters['status']);
    }
    if (!empty($filters['leave_type'])) {
        $sql .= " AND r.leave_type = " . $db->escape($filters['leave_type']);
    }
    if (!empty($filters['start_date'])) {
        $sql .= " AND r.end_date >= " . $db->escape($filters['start_date']);
    }
    if (!empty($filters['end_date'])) {
        $sql .= " AND r.start_date <= " . $db->escape($filters['end_date']);
    }
    
    $sql .= " ORDER BY r.created_at DESC";
    return $db->query($sql);
}

function get_pending_leave_requests(): ?object
{
    global $db;
    $sql = "SELECT r.*, e.name as employee_name FROM " . TB_PREF . "leave_requests r
        LEFT JOIN " . TB_PREF . "hr_employees e ON r.employee_id = e.id
        WHERE r.status = 'Pending' ORDER BY r.created_at ASC";
    return $db->query($sql);
}

function calculate_leave_days(string $start, string $end): float
{
    $start_ts = strtotime($start);
    $end_ts = strtotime($end);
    $holidays = get_holidays($start, $end);
    $days = 0;
    $current = $start_ts;
    while ($current <= $end_ts) {
        $day_of_week = date('N', $current);
        $date_str = date('Y-m-d', $current);
        if ($day_of_week < 6 && !isset($holidays[$date_str])) {
            $days++;
        }
        $current = strtotime('+1 day', $current);
    }
    return $days;
}

function get_holidays(string $start, string $end): array
{
    global $db;
    $sql = "SELECT date FROM " . TB_PREF . "leave_holidays WHERE date >= " . $db->escape($start) . " AND date <= " . $db->escape($end) . " AND active = 1";
    $result = $db->query($sql);
    $holidays = [];
    while ($row = $db->fetch($result)) {
        $holidays[$row['date']] = true;
    }
    return $holidays;
}

function get_leave_balance(int $employee_id, string $leave_type, int $year): ?array
{
    global $db;
    $sql = "SELECT * FROM " . TB_PREF . "leave_balances WHERE employee_id = " . $employee_id . " AND leave_type = " . $db->escape($leave_type) . " AND year = " . $year;
    $result = $db->query($sql);
    if ($result && $db->num_rows($result) > 0) {
        return $db->fetch($result);
    }
    return null;
}

function update_leave_balance(int $employee_id, string $leave_type, int $year, float $entitlement, float $used = 0, float $carried_forward = 0): bool
{
    global $db;
    $sql = "INSERT INTO " . TB_PREF . "leave_balances (employee_id, year, leave_type, entitlement, used, carried_forward)
        VALUES (" . $employee_id . ", " . $year . ", " . $db->escape($leave_type) . ", " . $entitlement . ", " . $used . ", " . $carried_forward . ")
        ON DUPLICATE KEY UPDATE entitlement = " . $entitlement . ", used = " . $used . ", carried_forward = " . $carried_forward;
    return $db->query($sql);
}