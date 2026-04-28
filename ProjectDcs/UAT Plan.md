# UAT Plan - ksf_FA_Leave

## Overview

This UAT (User Acceptance Testing) plan defines test cases for validating the Leave Management module (ksf_FA_Leave) against business requirements from an end-user perspective.

## UAT Objectives

1. Verify that leave request submission works correctly
2. Validate leave balance calculations are accurate
3. Confirm approval/rejection workflow functions properly
4. Ensure leave type configurations are properly applied
5. Verify accrual calculations are correct

## Test Environment

### Prerequisites
- Access to Leave Management module
- Test employee accounts with different roles
- Configured leave types (Annual, Sick, Unpaid)
- Pre-populated test balances

### Test User Roles

| Role | Permissions | Test Users |
|------|-------------|------------|
| Employee | Submit requests, view own balances | emp001, emp002 |
| Manager | Approve/reject team requests | mgr001 |
| HR Admin | Configure leave types, view all | hr001 |

## Test Cases

### TC-001: Submit Leave Request - Valid Request

**Objective**: Verify employee can submit a valid leave request

**Pre-conditions**:
- Employee has available leave balance
- Leave type is active

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "Leave Request" section
3. Select leave type: Annual Leave
4. Enter start date: 2024-07-01
5. Enter end date: 2024-07-05
6. Enter reason: "Summer vacation"
7. Submit request

**Expected Results**:
- Request is created successfully
- Status shows "Pending"
- Days calculated as 5 (inclusive)
- Available balance reduced by 5 (pending)

**Pass Criteria**: [ ]

---

### TC-002: Submit Leave Request - Insufficient Balance

**Objective**: Verify system prevents request exceeding available balance

**Pre-conditions**:
- Employee has 5 days available balance

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "Leave Request" section
3. Select leave type: Annual Leave
4. Enter start date: 2024-07-01
5. Enter end date: 2024-07-15 (10 days)
6. Enter reason: "Extended vacation"
7. Attempt to submit request

**Expected Results**:
- Validation error displayed
- Error message: "Insufficient leave balance. Available: 5"
- Request is NOT created

**Pass Criteria**: [ ]

---

### TC-003: Submit Leave Request - Past Date Rejection

**Objective**: Verify system rejects requests with start date in past

**Pre-conditions**:
- Current date is after any test leave period

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "Leave Request" section
3. Select leave type: Annual Leave
4. Enter start date: 2023-01-01 (past date)
5. Enter end date: 2023-01-05
6. Submit request

**Expected Results**:
- Validation error displayed
- Error message: "Start date cannot be in the past"
- Request is NOT created

**Pass Criteria**: [ ]

---

### TC-004: Submit Leave Request - Invalid Date Range

**Objective**: Verify system rejects when end date before start date

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "Leave Request" section
3. Select leave type: Annual Leave
4. Enter start date: 2024-07-10
5. Enter end date: 2024-07-05 (before start)
6. Submit request

**Expected Results**:
- Validation error displayed
- Error message: "End date must be after start date"
- Request is NOT created

**Pass Criteria**: [ ]

---

### TC-005: Approve Leave Request

**Objective**: Verify manager can approve pending leave request

**Pre-conditions**:
- Employee has submitted pending request

**Test Steps**:
1. Log in as manager (mgr001)
2. Navigate to "Pending Approvals" section
3. View pending leave requests
4. Select request from emp001
5. Click "Approve"
6. Confirm approval

**Expected Results**:
- Status changes to "Approved"
- Approver ID recorded
- Approval date set to today
- Employee notified (if notifications enabled)

**Pass Criteria**: [ ]

---

### TC-006: Reject Leave Request

**Objective**: Verify manager can reject leave request with reason

**Pre-conditions**:
- Employee has submitted pending request

**Test Steps**:
1. Log in as manager (mgr001)
2. Navigate to "Pending Approvals" section
3. View pending leave requests
4. Select request from emp001
5. Click "Reject"
6. Enter reason: "Team coverage insufficient"
7. Confirm rejection

**Expected Results**:
- Status changes to "Rejected"
- Rejection reason recorded
- Employee notified with reason

**Pass Criteria**: [ ]

---

### TC-007: Cancel Leave Request

**Objective**: Verify employee can cancel own pending request

**Pre-conditions**:
- Employee has submitted pending request

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "My Leave Requests"
3. View pending request
4. Click "Cancel"
5. Confirm cancellation

**Expected Results**:
- Status changes to "Cancelled"
- No balance deduction occurs

**Pass Criteria**: [ ]

---

### TC-008: View Leave Balance

**Objective**: Verify employee can view their leave balance

**Test Steps**:
1. Log in as employee (emp001)
2. Navigate to "My Leave Balance"
3. View balance for Annual Leave

**Expected Results**:
- Opening Balance: displayed
- Accrued: displayed
- Used: displayed
- Carried Forward: displayed
- Available: correctly calculated (Opening + Accrued + Carried - Used)

**Pass Criteria**: [ ]

---

### TC-009: Calculate Available Balance

**Objective**: Verify available balance calculation is accurate

**Test Data**:
- Opening Balance: 10 days
- Accrued: 5 days
- Used: 3 days
- Carried Forward: 0 days

**Test Steps**:
1. Log in as employee (emp001)
2. View Annual Leave balance

**Expected Results**:
- Available = 10 + 5 + 0 - 3 = 12 days
- Displayed correctly

**Pass Criteria**: [ ]

---

### TC-010: Accrual Calculation

**Objective**: Verify monthly accrual calculation is correct

**Test Data**:
- Leave Type: Annual Leave
- Annual Allowance: 15 days
- Months Worked: 3 months

**Test Steps**:
1. HR Admin initiates accrual calculation
2. System calculates for 3 months

**Expected Results**:
- Monthly Rate = 15 / 12 = 1.25 days/month
- Total Accrual = 1.25 * 3 = 3.75 days
- Rounded to 2 decimal places: 3.75 days

**Pass Criteria**: [ ]

---

### TC-011: Leave Type Configuration

**Objective**: Verify leave types are properly configured

**Test Steps**:
1. Log in as HR Admin (hr001)
2. Navigate to "Leave Types"
3. View Annual Leave configuration

**Expected Results**:
- Name: Annual Leave
- Code: AL
- Annual Allowance: 15 days
- Accrues: Yes
- Accrual Rate: 1.25 days/month
- Requires Approval: Yes
- Is Paid: Yes
- Active: Yes

**Pass Criteria**: [ ]

---

### TC-012: Negative Balance - Warning

**Objective**: Verify system warns when request exceeds balance but negative allowed

**Pre-conditions**:
- Leave type allows negative balance (e.g., Sick Leave)
- Employee has 2 days available
- Max negative balance: 5 days

**Test Steps**:
1. Log in as employee (emp001)
2. Request 4 days sick leave
3. Submit request

**Expected Results**:
- Warning displayed: "Warning: This will create a negative balance"
- Request can still be submitted
- Balance will go to -2 (allowed)

**Pass Criteria**: [ ]

---

### TC-013: Negative Balance - Exceeds Maximum

**Objective**: Verify system rejects when request exceeds max negative balance

**Pre-conditions**:
- Leave type allows negative balance
- Max negative balance: 3 days
- Employee has 2 days available

**Test Steps**:
1. Log in as employee (emp001)
2. Request 6 days leave
3. Attempt to submit

**Expected Results**:
- Error displayed: "Request exceeds maximum negative balance allowed"
- Request is NOT created

**Pass Criteria**: [ ]

---

### TC-014: Calculate Days - Inclusive

**Objective**: Verify day calculation includes start and end dates

**Test Data**:
- Start Date: 2024-07-01
- End Date: 2024-07-05

**Test Steps**:
1. Create leave request with date range
2. Check calculated days

**Expected Results**:
- Days = 5 (Jul 1, 2, 3, 4, 5)
- Calculation: (End - Start).days + 1

**Pass Criteria**: [ ]

---

### TC-015: Single Day Leave

**Objective**: Verify single day leave calculation

**Test Data**:
- Start Date: 2024-07-01
- End Date: 2024-07-01

**Test Steps**:
1. Create leave request for single day
2. Check calculated days

**Expected Results**:
- Days = 1

**Pass Criteria**: [ ]

---

### TC-016: Leave Type - Non-Accruing

**Objective**: Verify non-accruing leave types do not accrue

**Test Data**:
- Leave Type: Unpaid Leave
- Annual Allowance: 0
- Accrues: No

**Test Steps**:
1. System processes monthly accrual
2. Check unpaid leave balance

**Expected Results**:
- Accrual = 0 days
- Balance remains at opening value

**Pass Criteria**: [ ]

---

### TC-017: Carry Forward

**Objective**: Verify unused leave can be carried forward to next year

**Pre-conditions**:
- Employee has 5 unused days at year end
- Max carry forward: 5 days

**Test Steps**:
1. System processes year-end
2. Check new year balance

**Expected Results**:
- Opening Balance for new year: 5 days
- Carried Forward: 5 days
- Total Available: 5 + new accruals

**Pass Criteria**: [ ]

---

## Test Summary

| Category | Total Tests | Passed | Failed | Pass Rate |
|----------|-------------|--------|--------|-----------|
| Leave Request Submission | 4 | - | - | - |
| Leave Request Processing | 3 | - | - | - |
| Balance Management | 2 | - | - | - |
| Calculations | 3 | - | - | - |
| Configuration | 2 | - | - | - |
| Edge Cases | 3 | - | - | - |
| **TOTAL** | **17** | - | - | - |

## Defect Log

| Defect ID | Test Case | Severity | Description | Status |
|-----------|-----------|----------|-------------|--------|
| (To be filled during testing) | | | | |

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Owner | | | |
| Project Manager | | | |
| QA Lead | | | |
| Technical Lead | | | |

## Related Documents

- Functional Requirements.md
- Business Requirements.md
- Architecture.md
- Test Plan.md
- Use Case.md
- RTM.md
