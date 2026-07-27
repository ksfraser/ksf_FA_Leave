# AGENTS.md - ksf_FA_Leave

## Overview

FA Module for Leave Management - requests, approvals, balances, leave banks, accruals, and calendar/holidays.

### Core Principles
- SOLID, DRY, TDD, DI, SRP

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

## Development Workflow

All development is done in the **devel tree** (`~/Documents/ksf_FA_Leave`). Do **not** edit files in the UAT bind point directly.

### Workflow Steps
1. **Develop** in this repo (feature branches preferred)
2. **Test**: run repo-appropriate tests
3. **Lint**: `php -l` on modified PHP files (no syntax errors)
4. **Commit** and **Push** branch to GitHub
5. **Merge** to `main` when ready
6. **Push** `main` to GitHub
7. **Deploy** to UAT:

   ```
   cd ~/ksf_Infrastructure/fa_modules/ksf_FA_Leave
   git stash -u
   git pull origin main
   git stash pop
   ```

### UAT Bind Point
| Path | Purpose |
|------|---------|
| `~/Documents/ksf_FA_Leave` | Devel tree |
| `~/ksf_Infrastructure/fa_modules/ksf_FA_Leave` | UAT bind point |
