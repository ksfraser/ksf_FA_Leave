<!-- Repo-specific appendix to the shared AGENTS.md. Generic conventions live in AGENTS_ARCH.md (hardlinked). -->

# AGENTS.md - ksf_FA_Leave
## Overview
FA Module for Leave Management - requests, approvals, balances, leave banks, accruals, and calendar/holidays.
## Namespace Convention
- **FA Platform modules**: `ksfraser\FrontAccounting\<ModuleName>\`
- **Current**: `ksfraser\FrontAccounting\Leave\`
## Table Ownership
### Leave Tables (`0_leave_*`)
| Table | Purpose |
|-------|---------|
| `0_leave_types` | Leave type definitions (8 seeded: Annual, Sick, Personal, Maternity, Paternity, Bereavement, Unpaid, Other) |
| `0_leave_requests` | Leave applications (FK to person, employment, leave_type) |
| `0_leave_balances` | Employee leave balances (entitlement/used/balance/carry_over per year) |
| `0_leave_bank_config` | Accrual rules per leave type (unit, rate, max, allow negative) |
| `0_leave_banks` | Employee bank-based leave tracking (accrued/used/balance per year) |
| `0_leave_transactions` | Audit trail: accruals, usage, adjustments, carry-over, payout |
| `0_leave_holidays` | Public/company holidays |
| `0_leave_approval_matrix` | Who approves whose leave requests |
| `0_leave_settings` | Module configuration settings |
### NOT Owned by Leave
- **Leave types admin page** is in `ksf_FA_HRM` (pages/leave_types.php)
- **Employee records** → `ksf_FA_HRM` (`0_hrm_contacts_employment`)
- **Payroll** → `ksf_FA_HRM` (`0_ksf_hrm_payroll`)
## Dependencies
- FrontAccounting 2.4+ (core)
- ksf_FA_HRM (employee records, employment links)
- ksf_FA_CRM (person records - 0_crm_persons)
- PHP >=7.3
## Repository Structure
```
ksf_FA_Leave/
├── sql/
│   └── install.sql          # All Leave tables (0_ prefix)
├── includes/
│   └── leave_db.inc         # Leave balance DB queries
├── pages/                   # (future: leave request pages)
├── hooks.php                # FA module hooks
├── composer.json
├── tests/
│   └── Unit/
│       ├── HookTest.php
│       └── ModuleStructureTest.php
└── ProjectDcs/
```
