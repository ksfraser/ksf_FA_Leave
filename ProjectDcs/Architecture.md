# Architecture - ksf_FA_Leave

## Overview

This document describes the technical architecture of the Leave Management module (ksf_FA_Leave), providing FA-specific leave management functionality.

## Module Type

- **Type**: FA Module (ksfraser/ksf_fa_leave)
- **Dependency**: Base Leave module (ksfraser/ksf_Leave)
- **Dependency Manager**: composerdendencymanager

## Architecture Pattern

The module follows a **Domain-Driven Design (DDD)** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    ksf_FA_Leave Module                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Presentation Layer                       │   │
│  │         (pages/, includes/ - future)                  │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Application Layer                       │   │
│  │              (Service/LeaveService.php)               │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                Domain Layer                           │   │
│  │   (Entity/LeaveRequest.php, LeaveBalance.php,        │   │
│  │    LeaveType.php)                                     │   │
│  └──���──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   ksf_Leave (Base Module)                   │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
ksf_FA_Leave/
├── composer.json              # Module definition & dependencies
├── src/
│   ├── Entity/
│   │   ├── LeaveRequest.php   # Leave request domain entity
│   │   ├── LeaveBalance.php   # Leave balance domain entity
│   │   └── LeaveType.php      # Leave type configuration entity
│   └── Service/
│       └── LeaveService.php   # Business logic service
├── tests/
│   └── Unit/
│       └── Entity/
│           ├── LeaveRequestTest.php
│           ├── LeaveBalanceTest.php
│           └── LeaveTypeTest.php
├── pages/                      # UI pages (future)
├── includes/                   # Shared includes (future)
└── ProjectDcs/               # Documentation
```

## Component Architecture

### 1. Entity Layer

#### LeaveRequest Entity
```
LeaveRequest
├── Status Constants
│   ├── STATUS_PENDING
│   ├── STATUS_APPROVED
│   ├── STATUS_REJECTED
│   └── STATUS_CANCELLED
├── Properties
│   ├── id: int?
│   ├── employeeId: int
│   ├── leaveTypeId: int
│   ├── startDate: string
│   ├── endDate: string
│   ├── days: float
│   ├── reason: string
│   ├── status: string
│   ├── approverId: int?
│   ├── approvedDate: string?
│   ├── rejectionReason: string?
│   ��── replacesEmployeeId: int?
│   └── createdAt: string
└── Methods
    ├── getDays(): float (with auto-calculation)
    ├── calculateDays(): float
    └── Status check methods (isPending, isApproved, etc.)
```

#### LeaveBalance Entity
```
LeaveBalance
├── Properties
│   ├��─ id: int?
│   ├── employeeId: int
│   ├── leaveTypeId: int
│   ├── year: int
│   ├── openingBalance: float
│   ├── accrued: float
│   ├── used: float
│   ├── carriedForward: float
│   └── maxCarryForward: float?
└── Methods
    ├── getAvailable(): float
    ├── hasInsufficientFunds(float): bool
    ├── useDays(float): void
    └── addAccrual(float): void
```

#### LeaveType Entity
```
LeaveType
├── Properties
│   ├── id: int?
│   ├── name: string
│   ├── code: string
│   ├── description: string
│   ├── annualAllowance: float
│   ├── accrues: bool
│   ├── accrualRate: float
│   ├── requiresApproval: bool
│   ├── negativeAllowed: bool
│   ├── maxNegativeBalance: float
│   ├── glCodeExpense: string
│   ├── glCodeAccrual: string
│   ├── isPaid: bool
│   └── active: bool
└── Methods
    └── (Getters/Setters for all properties)
```

### 2. Service Layer

#### LeaveService
```
LeaveService
├── validateRequest(LeaveRequest, LeaveBalance, LeaveType): ValidationResult
│   ├── Checks balance sufficiency
│   ├── Validates date constraints
│   └── Returns errors/warnings array
├── approveRequest(LeaveRequest, int): void
│   └── Updates status, records approver
├── rejectRequest(LeaveRequest, int, string): void
│   └── Updates status, records rejection reason
└── calculateAccrual(LeaveType, float): float
    └── Calculates pro-rata accrual
```

## Data Flow

### Leave Request Submission Flow
```
User -> Submit Request Form
    -> LeaveRequest Entity Created
    -> Retrieve LeaveBalance for employee/type/year
    -> LeaveService.validateRequest()
        -> Check available balance
        -> Validate date range
        -> Return validation result
    -> If valid: Persist to database
    -> Return success/failure to user
```

### Leave Approval Flow
```
Manager -> View Pending Requests
    -> Select Request
    -> LeaveService.approveRequest()
        -> Update status to APPROVED
        -> Set approverId
        -> Set approvedDate
    -> Update LeaveBalance.used
    -> Persist changes
    -> Notify employee
```

## Database Schema

### Entity Relationship Diagram
```
┌─────────────────┐       ┌─────────────────┐
│   leave_types   │       │  leave_requests │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │◄──────│ leave_type_id   │
│ name            │       │ id (PK)         │
│ code            │       │ employee_id     │
│ description     │       │ status          │
│ annual_allowance│       │ start_date      │
│ accrues         │       │ end_date        │
│ accrual_rate    │       │ days            │
│ ...             │       │ approver_id     │
└─────────────────┘       │ ...             │
                          └─────────────────┘
                                 │
                                 ▼
                          ┌─────────────────┐
                          │  leave_balances │
                          ├─────────────────┤
                          │ id (PK)         │
                          │ employee_id     │
                          │ leave_type_id   │◄────┐
                          │ year            │      │
                          │ opening_balance │      │
                          │ accrued         │      │
                          │ used            │      │
                          │ carried_forward │      │
                          └─────────────────┘      │
                                 ▲                  │
                                 └──────────────────┘
```

### Table Definitions

#### leave_types
```sql
CREATE TABLE leave_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    description TEXT,
    annual_allowance DECIMAL(5,2) DEFAULT 0,
    accrues BOOLEAN DEFAULT TRUE,
    accrual_rate DECIMAL(5,2) DEFAULT 0,
    requires_approval BOOLEAN DEFAULT TRUE,
    negative_allowed BOOLEAN DEFAULT FALSE,
    max_negative_balance DECIMAL(5,2) DEFAULT 0,
    gl_code_expense VARCHAR(50),
    gl_code_accrual VARCHAR(50),
    is_paid BOOLEAN DEFAULT TRUE,
    active BOOLEAN DEFAULT TRUE
);
```

#### leave_requests
```sql
CREATE TABLE leave_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days DECIMAL(5,2) NOT NULL,
    reason TEXT,
    status ENUM('Pending', 'Approved', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    approver_id INT,
    approved_date DATE,
    rejection_reason TEXT,
    replaces_employee_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id)
);
```

#### leave_balances
```sql
CREATE TABLE leave_balances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    year INT NOT NULL,
    opening_balance DECIMAL(5,2) DEFAULT 0,
    accrued DECIMAL(5,2) DEFAULT 0,
    used DECIMAL(5,2) DEFAULT 0,
    carried_forward DECIMAL(5,2) DEFAULT 0,
    max_carry_forward DECIMAL(5,2),
    UNIQUE KEY unique_balance (employee_id, leave_type_id, year),
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id)
);
```

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | PHP 8.x+ |
| Testing | PHPUnit |
| Type Safety | PHPStan (future) |
| Coding Standard | PSR-12 |
| Dependency Management | Composer |

## Integration Points

### External Dependencies
1. **ksfraser/ksf_Leave** - Base leave functionality
2. **ksfraser/composerdendencymanager** - Module dependency management

### Future Integration
- HRIS System - Employee data synchronization
- Email Service - Notification delivery
- Calendar Integration - Calendar sync
- Reporting - BI/reporting integration

## Security Considerations

1. **Authorization**: Role-based access control (RBAC)
2. **Data Validation**: Input sanitization at all entry points
3. **Audit Logging**: Track all status changes
4. **SQL Injection Prevention**: Parameterized queries (at DB layer)

## Performance Considerations

1. **Indexing**: Proper indexes on foreign keys and status
2. **Caching**: Balance calculations can be cached
3. **Pagination**: Large result sets should be paginated
4. **Lazy Loading**: Related entities loaded on demand

## Error Handling

### Validation Errors
```php
[
    'valid' => false,
    'errors' => [
        'Insufficient leave balance. Available: 5',
        'Start date cannot be in the past'
    ],
    'warnings' => [
        'Warning: This will create a negative balance'
    ]
]
```

### Status Constants
```php
LeaveRequest::STATUS_PENDING    // 0 - Awaiting approval
LeaveRequest::STATUS_APPROVED   // 1 - Approved
LeaveRequest::STATUS_REJECTED   // 2 - Rejected
LeaveRequest::STATUS_CANCELLED  // 3 - Cancelled by user
```

## Testing Strategy

- **Unit Tests**: Entity and service layer tests
- **Integration Tests**: Database interactions (future)
- **Coverage Target**: 80%+ code coverage

## Related Documents

- Functional Requirements.md
- Business Requirements.md
- Test Plan.md
- UAT Plan.md
- Use Case.md
- RTM.md
