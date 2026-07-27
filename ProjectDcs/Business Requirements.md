# Business Requirements - ksf_FA_Leave

## Overview
ksf_FA_Leave is the FrontAccounting module for Leave Management. It provides leave requests, approvals, balance tracking, accrual banks, and holiday management.

## Module Responsibilities

### What Leave Owns
- Leave type definitions (master list)
- Leave request workflow (submit → approve/reject)
- Leave balance tracking (per employee, per type, per year)
- Leave bank system (configurable accrual, carry-over, negative balance rules)
- Leave transaction audit trail
- Holiday calendar
- Approval matrix

### What Leave Does NOT Own
- Leave types admin UI → `ksf_FA_HRM` (pages/leave_types.php)
- Employee records → `ksf_FA_HRM` (0_hrm_contacts_employment)
- Payroll deductions for leave → `ksf_FA_HRM` (0_ksf_hrm_payroll)

## FA-Specific Features

### Database
- FA-compliant table naming: `0_leave_*` prefix
- FKs to HRM: `0_hrm_contacts_employment.employment_id`
- FKs to CRM: `0_crm_persons.id`

### UI
- Leave types admin page (in ksf_FA_HRM)
- Leave balances view (in ksf_FA_HRM)

### Integration
- Accrual runs can tie to payroll periods
- Termination triggers bank zeroing
- Year-end carry-over processing

## Dependencies
- FrontAccounting 2.4+
- ksf_FA_HRM (employee/employment records)
- ksf_FA_CRM (person records)
- PHP >=7.3

*Document Version: 2.0.0*
*Last Updated: 2026-07-27*
