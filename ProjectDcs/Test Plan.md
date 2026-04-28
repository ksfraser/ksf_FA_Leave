# Test Plan - ksf_FA_Leave

## Overview

This test plan outlines the testing strategy for the Leave Management module (ksf_FA_Leave), covering unit testing, integration testing, and quality assurance activities.

## Scope

### In Scope
- Entity unit tests (LeaveRequest, LeaveBalance, LeaveType)
- Service unit tests (LeaveService)
- Code coverage analysis
- Basic functionality verification

### Out of Scope
- Database integration tests (pending database layer)
- UI/UX testing (pages/ directory not implemented)
- Performance testing
- Security penetration testing

## Test Strategy

### Testing Pyramid
```
         ┌─────────────┐
         │   UAT/E2E   │  <- Manual testing
         ├─────────────┤
         │ Integration │  <- Future (with DB)
         ├─────────────┤
         │    Unit     │  <- Current focus
         └─────────────┘
```

## Test Environment

### Local Development
- PHP 8.x
- PHPUnit (installed via composer)
- Code coverage enabled

### Test Execution
```bash
# Run all tests
./vendor/bin/phpunit

# Run with coverage
./vendor/bin/phpunit --coverage-html coverage/

# Run specific test class
./vendor/bin/phpunit tests/Unit/Entity/LeaveRequestTest.php
```

## Unit Test Specifications

### 1. LeaveRequest Entity Tests

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| LR-001 | testCanCreateLeaveRequest | Verify LeaveRequest instantiation | Object created successfully |
| LR-002 | testCanSetAndGetEmployeeId | Test employee ID getter/setter | Value correctly stored/retrieved |
| LR-003 | testCanSetAndGetLeaveType | Test leave type ID getter/setter | Value correctly stored/retrieved |
| LR-004 | testCanSetStartAndEndDates | Test date range assignment | Both dates correctly stored |
| LR-005 | testCanCalculateDays | Test automatic day calculation | Correct day count (inclusive) |
| LR-006 | testCanSetStatus | Test status assignment | Status correctly stored |
| LR-007 | testCanCheckIfApproved | Test approved status check | Returns true when approved |
| LR-008 | testCanCheckIfPending | Test pending status check | Returns true when pending |

**Test Scenarios**:
- Create request with valid data
- Set and retrieve employee ID
- Set and retrieve leave type ID
- Set date range (e.g., July 1-5 = 5 days)
- Check status flags work correctly

### 2. LeaveBalance Entity Tests

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| LB-001 | testCanCreateLeaveBalance | Verify LeaveBalance instantiation | Object created successfully |
| LB-002 | testCanSetAndGetValues | Test all balance property accessors | All values stored/retrieved correctly |
| LB-003 | testCanCalculateAvailable | Test available balance calculation | Available = Opening + Accrued + Carried - Used |
| LB-004 | testCanCheckInsufficientFunds | Test insufficient funds check | Correct boolean returned |

**Test Scenarios**:
- Create balance with all fields
- Calculate available: 10 + 2 - 3 = 9
- Check insufficient: 2 days available, request 3 = true
- Check sufficient: 3 days available, request 3 = false

### 3. LeaveType Entity Tests

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| LT-001 | testCanCreateLeaveType | Verify LeaveType instantiation | Object created successfully |
| LT-002 | testCanSetAndGetId | Test ID getter/setter | Value correctly stored/retrieved |
| LT-003 | testCanSetAndGetName | Test name getter/setter | Value correctly stored/retrieved |
| LT-004 | testCanSetAndGetCode | Test code getter/setter | Value correctly stored/retrieved |
| LT-005 | testCanSetAnnualAllowance | Test annual allowance setting | Value correctly stored/retrieved |
| LT-006 | testCanCheckIfAccrues | Test accrual flag check | Correct boolean returned |
| LT-007 | testCanCheckIfRequiresApproval | Test approval requirement check | Correct boolean returned |
| LT-008 | testCanSetAndGetAccrualRate | Test accrual rate setting | Value correctly stored/retrieved |
| LT-009 | testCanCheckIsActive | Test active status check | Correct boolean returned |

**Test Scenarios**:
- Create leave type (e.g., Annual Leave)
- Set code (e.g., "AL")
- Set annual allowance (e.g., 15 days)
- Check accrual enabled/disabled
- Check approval requirement

### 4. LeaveService Tests (Future)

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| LS-001 | testValidateRequest_SufficientBalance | Validate request with sufficient balance | valid = true |
| LS-002 | testValidateRequest_InsufficientBalance | Validate request with insufficient balance | Error returned |
| LS-003 | testValidateRequest_PastStartDate | Validate request with past date | Error returned |
| LS-004 | testValidateRequest_InvalidDateRange | Validate request where end < start | Error returned |
| LS-005 | testApproveRequest | Test approval workflow | Status = Approved, approverId set |
| LS-006 | testRejectRequest | Test rejection workflow | Status = Rejected, reason set |
| LS-007 | testCalculateAccrual | Test accrual calculation | Correct monthly amount |

**Test Scenarios**:
- Validation: Sufficient balance
- Validation: Insufficient balance (negative not allowed)
- Validation: Insufficient balance (negative allowed - warning)
- Validation: Start date in past
- Validation: End date before start date
- Approval: Set status and approver
- Rejection: Set status and reason
- Accrual: 15 days/year = 1.25/month

## Test Data Requirements

### Leave Types
| Code | Name | Annual Allowance | Accrues |
|------|------|------------------|---------|
| AL | Annual Leave | 15 | Yes |
| SL | Sick Leave | 10 | Yes |
| UL | Unpaid Leave | 0 | No |

### Test Employees
| Employee ID | Name | Department |
|-------------|------|------------|
| 1 | Test Employee 1 | Engineering |
| 2 | Test Employee 2 | Engineering |
| 3 | Manager 1 | Engineering |

### Test Balances
| Employee | Leave Type | Year | Opening | Accrued | Used |
|----------|------------|------|---------|---------|------|
| 1 | AL | 2024 | 10 | 5 | 3 |
| 1 | SL | 2024 | 5 | 0 | 1 |
| 2 | AL | 2024 | 15 | 0 | 0 |

## Code Coverage

### Current Coverage
| Component | Coverage Target |
|-----------|-----------------|
| LeaveRequest.php | 80%+ |
| LeaveBalance.php | 80%+ |
| LeaveType.php | 80%+ |
| LeaveService.php | 80%+ |
| **Total Module** | **80%+** |

### Coverage Report
```bash
./vendor/bin/phpunit --coverage-html coverage/
```

## Defect Management

### Defect Lifecycle
```
New -> Assigned -> In Progress -> Fixed -> Verified -> Closed
```

### Severity Classification
| Severity | Description | Example |
|----------|-------------|---------|
| Critical | System unusable | Module crashes on load |
| High | Major function broken | Cannot create leave request |
| Medium | Function impaired | Balance calculation wrong |
| Low | Minor issue | Typos, cosmetic issues |

### Known Limitations
1. No database persistence tests (infrastructure pending)
2. No integration tests with ksf_Leave base module
3. No UI tests (pages/ not implemented)

## Test Schedule

| Phase | Activity | Status |
|-------|----------|--------|
| Phase 1 | Entity unit tests | Complete |
| Phase 2 | Service unit tests | Pending |
| Phase 3 | Integration tests | Planned |
| Phase 4 | Coverage optimization | Planned |

## Success Criteria

- [ ] All unit tests pass
- [ ] Code coverage >= 80%
- [ ] No critical or high severity defects
- [ ] All acceptance criteria in Functional Requirements covered

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| PHPUnit | Test framework |
| Xdebug | Code coverage |
| PHPStan | Static analysis (future) |

## Related Documents

- Functional Requirements.md
- Architecture.md
- UAT Plan.md
- Use Case.md
- RTM.md
