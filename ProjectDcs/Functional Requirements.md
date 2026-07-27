# Functional Requirements - ksf_FA_Leave

## Overview

This document details the functional requirements for the Leave Management module (ksf_FA_Leave), which extends the base Leave module to provide FA-specific leave management functionality.

## Scope

The module handles:
- Leave request submission and tracking
- Leave balance management
- Leave type configuration
- Approval workflow
- Accrual calculation

---

## FR-1: Leave Request Management

### FR-1.1: Submit Leave Request

**Description**: Employees shall be able to submit leave requests specifying dates, leave type, and reason.

**Requirements**:
- FR-1.1.1: System shall accept employee ID, leave type ID, start date, end date, and reason
- FR-1.1.2: System shall calculate the number of days automatically from date range
- FR-1.1.3: System shall validate sufficient leave balance exists
- FR-1.1.4: System shall set initial status to "Pending"
- FR-1.1.5: System shall record submission timestamp

**Acceptance Criteria**:
- [ ] Request can be created with all required fields
- [ ] Days calculation includes start and end dates
- [ ] Balance validation prevents over-requesting when negative not allowed
- [ ] Status defaults to Pending

### FR-1.2: View Leave Requests

**Description**: Users shall be able to view leave request history.

**Requirements**:
- FR-1.2.1: System shall allow viewing by employee ID
- FR-1.2.2: System shall support filtering by status
- FR-1.2.3: System shall display current status for each request

**Acceptance Criteria**:
- [ ] Employee can view their own requests
- [ ] Manager can view team requests
- [ ] Status filtering works correctly

### FR-1.3: Cancel Leave Request

**Description**: Employees shall be able to cancel their own pending requests.

**Requirements**:
- FR-1.3.1: System shall allow cancellation only when status is Pending
- FR-1.3.2: System shall update status to Cancelled
- FR-1.3.3: System shall not allow cancellation of approved requests

**Acceptance Criteria**:
- [ ] Pending request can be cancelled
- [ ] Cancelled status is correctly set
- [ ] Approved request cannot be cancelled

---

## FR-2: Leave Balance Management

### FR-2.1: View Leave Balance

**Description**: Users shall be able to view their current leave balance.

**Requirements**:
- FR-2.1.1: System shall calculate available balance as: Opening + Accrued + CarriedForward - Used
- FR-2.1.2: System shall display balance by leave type
- FR-2.1.3: System shall filter by year

**Acceptance Criteria**:
- [ ] Available balance is correctly calculated
- [ ] Balance shows breakdown of components
- [ ] Year filtering works correctly

### FR-2.2: Check Sufficient Funds

**Description**: System shall validate if sufficient leave balance exists for a request.

**Requirements**:
- FR-2.2.1: System shall compare requested days against available balance
- FR-2.2.2: System shall consider negative balance allowance if configured
- FR-2.2.3: System shall return boolean result

**Acceptance Criteria**:
- [ ] Returns false when days <= available
- [ ] Returns true when days > available
- [ ] Negative allowance is considered when configured

### FR-2.3: Track Leave Usage

**Description**: System shall track leave usage against balances.

**Requirements**:
- FR-2.3.1: System shall record days used against balance
- FR-2.3.2: System shall update used amount when request is approved
- FR-2.3.3: System shall support multiple requests per year

**Acceptance Criteria**:
- [ ] Used amount increments correctly
- [ ] Multiple requests accumulate correctly
- [ ] Year-specific tracking works

---

## FR-3: Leave Type Configuration

### FR-3.1: Configure Leave Type

**Description**: Administrators shall be able to configure leave types with specific rules.

**Requirements**:
- FR-3.1.1: System shall support configurable annual allowance
- FR-3.1.2: System shall support accrual enable/disable
- FR-3.1.3: System shall support accrual rate setting
- FR-3.1.4: System shall support approval requirement setting
- FR-3.1.5: System shall support negative balance settings
- FR-3.1.6: System shall support GL code mapping

**Acceptance Criteria**:
- [ ] Leave type can be created with all configuration options
- [ ] Each setting is correctly stored and retrieved
- [ ] GL codes are associated correctly

### FR-3.2: Leave Type Properties

**Description**: Each leave type shall have specific business rules.

**Requirements**:
- FR-3.2.1: Annual allowance defines total days per year
- FR-3.2.2: Accrual rate defines monthly accumulation (default: annual/12)
- FR-3.2.3: Requires approval flag controls approval workflow
- FR-3.2.4: Negative allowed flag permits balance overdraw
- FR-3.2.5: Is paid flag determines if leave is paid

**Acceptance Criteria**:
- [ ] All properties are configurable
- [ ] Default values are appropriate
- [ ] Active flag controls availability

---

## FR-4: Approval Workflow

### FR-4.1: Approve Leave Request

**Description**: Managers shall be able to approve pending leave requests.

**Requirements**:
- FR-4.1.1: System shall update status to Approved
- FR-4.1.2: System shall record approver ID
- FR-4.1.3: System shall record approval date
- FR-4.1.4: System shall deduct from leave balance

**Acceptance Criteria**:
- [ ] Status changes to Approved
- [ ] Approver and date are recorded
- [ ] Balance is updated

### FR-4.2: Reject Leave Request

**Description**: Managers shall be able to reject leave requests with reason.

**Requirements**:
- FR-4.2.1: System shall update status to Rejected
- FR-4.2.2: System shall record approver ID
- FR-4.2.3: System shall require and record rejection reason
- FR-4.2.4: System shall not affect leave balance

**Acceptance Criteria**:
- [ ] Status changes to Rejected
- [ ] Rejection reason is mandatory and stored
- [ ] Balance is not affected

### FR-4.3: Validation Before Approval

**Description**: System shall validate requests before allowing approval.

**Requirements**:
- FR-4.3.1: System shall validate start date is in the future
- FR-4.3.2: System shall validate end date is after start date
- FR-4.3.3: System shall validate sufficient balance or negative allowed
- FR-4.3.4: System shall return validation errors

**Acceptance Criteria**:
- [ ] Past dates are rejected
- [ ] Invalid date ranges are rejected
- [ ] Insufficient balance generates warning/error

---

## FR-5: Accrual Management

### FR-5.1: Calculate Accrual

**Description**: System shall calculate leave accruals based on leave type settings.

**Requirements**:
- FR-5.1.1: System shall calculate monthly accrual as: annual_allowance / 12
- FR-5.1.2: System shall only accrue for leave types with accrual enabled
- FR-5.1.3: System shall multiply by months worked

**Acceptance Criteria**:
- [ ] Monthly rate is correctly calculated
- [ ] Non-accruing leave types return 0
- [ ] Pro-rata calculation works correctly

### FR-5.2: Add Accrual

**Description**: System shall allow adding accruals to balances.

**Requirements**:
- FR-5.2.1: System shall increment accrued amount
- FR-5.2.2: System shall record transaction date
- FR-5.2.3: System shall support manual adjustments

**Acceptance Criteria**:
- [ ] Accrued amount increases correctly
- [ ] Accrual is traceable
- [ ] Manual adjustments are possible

---

## FR-6: Carry Forward

### FR-6.1: Year-End Carry Forward

**Description**: System shall handle carry forward of unused leave to next year.

**Requirements**:
- FR-6.1.1: System shall calculate unused days
- FR-6.1.2: System shall respect maximum carry forward limit
- FR-6.1.3: System shall create new year balance entry

**Acceptance Criteria**:
- [ ] Unused days are calculated correctly
- [ ] Carry forward respects maximum limit
- [ ] New year balance is created

---

## Non-Functional Requirements

### NFR-1: Performance
- Leave balance calculation: < 100ms
- Request validation: < 50ms

### NFR-2: Security
- Employees can only view/cancel own requests
- Managers can only approve team requests
- Audit trail for all status changes

### NFR-3: Data Integrity
- All monetary/balance values stored with 2 decimal precision
- Date fields stored in ISO format (YYYY-MM-DD)
- Timestamps in UTC

---

## Related Documents

- Business Requirements.md
- Architecture.md
- Test Plan.md
- UAT Plan.md
- Use Case.md
- RTM.md
