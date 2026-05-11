# AGENTS.md - ksf_FA_Leave#

## Architecture Overview#

**FA Module** for Leave Management - requests, approvals, balances, and calendar integration with HRM.

### Core Principles#
- **SOLID**, **DRY**, **TDD**, **DI**, **SRP**#

## Repository Structure#

```
ksf_FA_Leave/
├── sql/#
│   ├── fa_leave_types.sql#
│   ├── fa_leave_requests.sql#
│   ├── fa_leave_balances.sql#
│   └── fa_leave_approvals.sql#
├── includes/#
│   ├── leave_types_db.inc#
│   ├── requests_db.inc#
│   ├── balances_db.inc#
│   └── approvals_db.inc#
├── pages/#
├── hooks.php#
├── composer.json#
└── ProjectDocs/#
```

## Dependencies#

- **ksf_FA_Leave_Core** (business logic)#
- **ksf_FA_HRM** (link to employees)#
- **FrontAccounting 2.4+**#
