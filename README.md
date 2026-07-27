# ksf_FA_Leave - Leave Management Module

FA module for managing employee leave requests and balances.

## Overview

The Leave Management module provides functionality for employees to submit leave requests, track their leave balances, and for managers to approve or reject leave requests.

## Features

### Core Features
- **Leave Request Management**: Submit, track, approve, and reject leave requests
- **Balance Tracking**: Track opening balance, accruals, usage, and carried forward days
- **Leave Type Configuration**: Configure different leave types (vacation, sick, etc.) with custom rules
- **Accrual System**: Automatic accrual calculation based on leave type settings
- **Approval Workflow**: Multi-level approval process with status tracking

### Leave Types
- Configurable annual allowance per leave type
- Accrual rate settings (monthly accrual calculation)
- Negative balance tolerance settings
- Approval requirements
- GL code mapping for accounting integration

### Status Flow
```
Pending -> Approved
Pending -> Rejected
Any -> Cancelled
```

## Quick Start

### Installation

```bash
composer require ksfraser/ksf_fa_leave
```

### Basic Usage

```php
use Ksfraser\Leave\Entity\LeaveRequest;
use Ksfraser\Leave\Entity\LeaveBalance;
use Ksfraser\Leave\Entity\LeaveType;
use Ksfraser\Leave\Service\LeaveService;

// Create a leave request
$request = new LeaveRequest();
$request->setEmployeeId(1)
        ->setLeaveTypeId(1)
        ->setStartDate('2024-07-01')
        ->setEndDate('2024-07-05')
        ->setReason('Vacation');

// Get balance and validate
$balance = new LeaveBalance();
$balance->setOpeningBalance(10)
        ->setAccrued(5)
        ->setUsed(2);

$leaveType = new LeaveType();
$leaveType->setAnnualAllowance(15)
          ->setNegativeAllowed(false);

$service = new LeaveService();
$result = $service->validateRequest($request, $balance, $leaveType);

if ($result['valid']) {
    // Submit the request
}
```

## Database Tables

The module expects the following database tables:

### leave_requests
| Column | Type | Description |
|--------|------|-------------|
| id | INT (PK) | Primary key |
| employee_id | INT | Reference to employee |
| leave_type_id | INT | Reference to leave type |
| start_date | DATE | Leave start date |
| end_date | DATE | Leave end date |
| days | DECIMAL | Number of days requested |
| reason | TEXT | Reason for leave |
| status | ENUM | Pending/Approved/Rejected/Cancelled |
| approver_id | INT | Approving manager ID |
| approved_date | DATE | Date of approval |
| rejection_reason | TEXT | Reason if rejected |
| replaces_employee_id | INT | Covering employee |
| created_at | TIMESTAMP | Record creation time |

### leave_balances
| Column | Type | Description |
|--------|------|-------------|
| id | INT (PK) | Primary key |
| employee_id | INT | Reference to employee |
| leave_type_id | INT | Reference to leave type |
| year | INT | Leave year |
| opening_balance | DECIMAL | Balance at year start |
| accrued | DECIMAL | Days accrued this year |
| used | DECIMAL | Days used this year |
| carried_forward | DECIMAL | Days carried from previous year |
| max_carry_forward | DECIMAL | Maximum carry forward allowed |

### leave_types
| Column | Type | Description |
|--------|------|-------------|
| id | INT (PK) | Primary key |
| name | VARCHAR | Leave type name |
| code | VARCHAR | Short code (e.g., VAC, SIC) |
| description | TEXT | Detailed description |
| annual_allowance | DECIMAL | Annual entitlement |
| accrues | BOOLEAN | Auto-accrual enabled |
| accrual_rate | DECIMAL | Monthly accrual rate |
| requires_approval | BOOLEAN | Approval required |
| negative_allowed | BOOLEAN | Allow negative balance |
| max_negative_balance | DECIMAL | Maximum negative allowed |
| gl_code_expense | VARCHAR | GL expense code |
| gl_code_accrual | VARCHAR | GL accrual code |
| is_paid | BOOLEAN | Paid leave |
| active | BOOLEAN | Type is active |

## Permissions

### Employee Permissions
- Submit leave requests
- View own leave balances
- View own leave request history
- Cancel own pending requests

### Manager Permissions
- View team leave balances
- View team leave requests
- Approve/reject team leave requests
- Add accruals

### HR/Admin Permissions
- Configure leave types
- Modify any leave balances
- View all leave reports
- Process year-end carry forward

## API Reference

### LeaveRequest Entity

```php
// Status constants
LeaveRequest::STATUS_PENDING
LeaveRequest::STATUS_APPROVED
LeaveRequest::STATUS_REJECTED
LeaveRequest::STATUS_CANCELLED

// Methods
$request->getId(): ?int
$request->getEmployeeId(): int
$request->getLeaveTypeId(): int
$request->getStartDate(): string
$request->getEndDate(): string
$request->getDays(): float
$request->getReason(): string
$request->getStatus(): string
$request->getApproverId(): ?int
$request->getApprovedDate(): ?string
$request->getRejectionReason(): ?string
$request->getReplacesEmployeeId(): ?int
$request->getCreatedAt(): string

// Status checks
$request->isPending(): bool
$request->isApproved(): bool
$request->isRejected(): bool
$request->isCancelled(): bool
```

### LeaveBalance Entity

```php
// Methods
$balance->getId(): ?int
$balance->getEmployeeId(): int
$balance->getLeaveTypeId(): int
$balance->getYear(): int
$balance->getOpeningBalance(): float
$balance->getAccrued(): float
$balance->getUsed(): float
$balance->getCarriedForward(): float
$balance->getMaxCarryForward(): ?float
$balance->getAvailable(): float
$balance->hasInsufficientFunds(float $days): bool
```

### LeaveType Entity

```php
// Methods
$type->getId(): ?int
$type->getName(): string
$type->getCode(): string
$type->getDescription(): string
$type->getAnnualAllowance(): float
$type->accrues(): bool
$type->getAccrualRate(): float
$type->requiresApproval(): bool
$type->isNegativeAllowed(): bool
$type->getMaxNegativeBalance(): float
$type->getGlCodeExpense(): string
$type->getGlCodeAccrual(): string
$type->isPaid(): bool
$type->isActive(): bool
```

### LeaveService

```php
// Validation
$service->validateRequest(LeaveRequest $request, LeaveBalance $balance, LeaveType $leaveType): array
// Returns: ['valid' => bool, 'errors' => string[], 'warnings' => string[]]

// Approval
$service->approveRequest(LeaveRequest $request, int $approverId): void

// Rejection
$service->rejectRequest(LeaveRequest $request, int $approverId, string $reason): void

// Accrual Calculation
$service->calculateAccrual(LeaveType $leaveType, float $monthsWorked): float
```

## Configuration

### Example Leave Type Configuration

| Name | Code | Annual Allowance | Accrues | Accrual Rate |
|------|------|------------------|---------|--------------|
| Annual Leave | AL | 15 days | Yes | 1.25 days/month |
| Sick Leave | SL | 10 days | Yes | 0.83 days/month |
| Unpaid Leave | UL | 0 | No | N/A |

## Testing

Run unit tests:

```bash
./vendor/bin/phpunit
```

## Module Structure

```
ksf_FA_Leave/
├── composer.json
├── src/
│   ├── Entity/
│   │   ├── LeaveRequest.php
│   │   ├── LeaveBalance.php
│   │   └── LeaveType.php
│   └── Service/
│       └── LeaveService.php
├── tests/
│   └── Unit/
│       └── Entity/
│           ├── LeaveRequestTest.php
│           ├── LeaveBalanceTest.php
│           └── LeaveTypeTest.php
└── ProjectDcs/
    ├── Architecture.md
    ├── Functional Requirements.md
    ├── Business Requirements.md
    ├── Test Plan.md
    ├── UAT Plan.md
    ├── Use Case.md
    └── RTM.md
```

## License

Proprietary - KS Fraser Application Framework
