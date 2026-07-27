# Architecture - ksf_FA_Leave

## Overview

Technical architecture of the Leave Management module for FrontAccounting.

## Module Type

- **Type**: FA Module
- **Namespace**: `ksfraser\FrontAccounting\Leave\`
- **Tables**: `0_leave_*` prefix

## Database Schema

### Entity Relationship Diagram

```
┌──────────────────┐
│  0_leave_types   │
│ leave_type_id PK │
│ type_code UNIQUE │
│ type_name        │
│ default_days     │
│ is_paid          │
│ is_active        │
└───────┬──────────┘
        │ leave_type_id FK
        ├──────────────────────────────────┐
        ▼                                  ▼
┌──────────────────┐             ┌──────────────────────┐
│ 0_leave_requests │             │ 0_leave_bank_config  │
│ request_id PK    │             │ config_id PK         │
│ person_id FK ────┤──┐          │ leave_type_id FK     │
│ employment_id FK │  │          │ accrual_unit (Days/  │
│ leave_type_id FK │  │          │   Hours/Dollars)     │
│ start_date       │  │          │ annual_accrual       │
│ end_date         │  │          │ accrual_rate         │
│ days             │  │          │ max_balance          │
│ status           │  │          │ allow_negative       │
│ approved_by FK   │  │          │ on_depletion         │
└──────────────────┘  │          └──────────────────────┘
                      │
                      │          ┌──────────────────────┐
                      │          │   0_leave_banks      │
                      │          │ bank_id PK           │
                      ├─────────<│ employment_id FK     │
                      │          │ leave_type_id FK     │
                      │          │ year                 │
                      │          │ accrued / used /     │
                      │          │   balance            │
                      │          │ carry_over           │
                      │          └──────────────────────┘
                      │
                      │          ┌──────────────────────┐
                      │          │0_leave_transactions  │
                      │          │transaction_id PK     │
                      ├─────────<│ employment_id FK     │
                      │          │ leave_type_id FK     │
                      │          │ transaction_type     │
                      │          │ amount / balance_    │
                      │          │   after              │
                      │          │ reference_type/id    │
                      │          └──────────────────────┘
                      │
                      │          ┌──────────────────────┐
                      │          │0_leave_balances      │
                      │          │balance_id PK         │
                      └─────────<│ person_id FK         │
                                 │ leave_type_id FK     │
                                 │ year                 │
                                 │ entitlement / used / │
                                 │   balance            │
                                 │ carry_over           │
                                 └──────────────────────┘

┌───────────────────────┐    ┌────────────────────────┐
│0_leave_approval_matrix│    │   0_leave_holidays     │
│ matrix_id PK          │    │ holiday_id PK          │
│ employee_person_id FK │    │ holiday_date UNIQUE    │
│ approver_person_id FK │    │ holiday_name           │
│ leave_type_id FK      │    │ holiday_type           │
└───────────────────────┘    └────────────────────────┘

┌───────────────────────┐
│   0_leave_settings    │
│ setting_id PK         │
│ setting_key UNIQUE    │
│ setting_value         │
└───────────────────────┘
```

### Table Details

#### 0_leave_types
8 seeded types: ANNUAL(20d), SICK(10d), PERSONAL(5d), MATERNITY(90d), PATERNITY(5d), BEREAVEMENT(3d), UNPAID(0d), OTHER(0d)

#### 0_leave_bank_config
Default configs for 5 paid types. Annual: 1.6667/mo accrual, 40d max. Sick: 0.8333/mo, 20d max. Personal: 0.4167/mo, 10d max.

#### 0_leave_transactions
Transaction types: Accrual, Usage, Adjustment, CarryOver, Payout. References to Payroll, LeaveRequest, Manual, Termination.

## Technology Stack

| Component | Technology |
|-----------|------------|
| Platform | FrontAccounting 2.4+ |
| Language | PHP 7.3+ |
| Database | MySQL/MariaDB |
| Testing | PHPUnit |

## Integration Points

### HRM Integration
- Employee lookup via `0_hrm_contacts_employment` (employment_id)
- Person lookup via `0_crm_persons` (person_id)
- Leave types managed by HRM module but owned by Leave module

### Payroll Integration
- Leave transactions reference payroll runs
- Leave payout calculations for termination
- Balance carry-over at year end

## Security

- FA access areas: SA_HRM_LEAVE
- PII separation (leave balances are not PII)
- Audit trail via `0_leave_transactions`

*Document Version: 2.0.0*
*Last Updated: 2026-07-27*
