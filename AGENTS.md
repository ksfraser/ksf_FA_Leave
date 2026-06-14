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

## Development Workflow

All development is done in the **devel tree** (`~/Documents/ksf_FA_Leave`). Do **not** edit files in the UAT bind point directly.

### Workflow Steps
1. **Develop** in this repo (feature branches preferred)
2. **Test**: run repo-appropriate tests
3. **Lint**: `php -l` on modified PHP files (no syntax errors)
4. **Commit** and **Push** branch to GitHub
5. **Merge** to `master` when ready
6. **Push** `master` to GitHub
7. **Deploy** to UAT by pulling in the Infrastructure bind point:

   ```
   cd ~/ksf_Infrastructure/fa_modules/ksf_FA_Leave
   git stash -u
   git pull origin master
   git stash pop
   ```

### UAT Bind Point
| Path | Purpose |
|------|---------|
| `~/Documents/ksf_FA_Leave` | Devel tree — all development, testing, commits |
| `~/ksf_Infrastructure/fa_modules/ksf_FA_Leave` | UAT bind point — deployment target, integration testing (if mirrored) |

