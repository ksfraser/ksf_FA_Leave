# FA Leave Module - Access Control Specification

## Document Information

| Field | Value |
|-------|-------|
| Document Title | Access Control Specification |
| Module | ksf_FA_Leave |
| Version | 1.0.0 |
| Author | KSF Development Team |
| Last Updated | May 2026 |

---

## 1. Access Control Overview

### 1.1 Purpose

This document defines access control rules for ksf_FA_Leave:
- **Employees** see and manage their own leave
- **Managers** approve/deny team leave requests
- **HR** manages leave policies and balances
- **System Admin** has full access

### 1.2 Key Principles

| Principle | Description |
|-----------|-------------|
| Self-Service | Employees request and track own leave |
| Manager Approval | Managers control team availability |
| Privacy | Leave reasons confidential except to approvers |
| Accrual Accuracy | Balance calculations automated |

---

## 2. Role Definitions

| Role | Access Level |
|------|--------------|
| Employee | Own leave only |
| Manager | Own + approve team leave |
| HR Manager | All leave data + policies |
| HR Admin | Full access + configuration |

---

## 3. Record-Level Access

### 3.1 Leave Request Fields

| Field | Employee | Manager | HR Manager | HR Admin |
|-------|----------|---------|------------|----------|
| Leave Type | Read | Read | Read | Read/Write |
| Start/End Dates | Read/Write | Read | Read | Read/Write |
| Reason | Read/Write | Read | Read | Read/Write |
| Status | Read | Read/Write | Read | Read/Write |
| Manager Notes | Hidden | Read/Write | Read | Read/Write |
| HR Notes | Hidden | Hidden | Read/Write | Read/Write |
| Balance Before/After | Read | Read (team) | Read | Read |

### 3.2 Leave Balance

| Field | Employee | Manager | HR Manager | HR Admin |
|-------|----------|---------|------------|----------|
| Current Balance | Read (own) | Read (team) | Read | Read/Write |
| Accrual History | Read (own) | Hidden | Read | Read/Write |
| Leave Usage History | Read (own) | Read (team) | Read | Read/Write |
| Carryover | Read (own) | Read (team) | Read | Read/Write |

---

## 4. Leave Approval Workflow

### 4.1 Access by Stage

```
Request → Pending → Manager Review → HR Review → Approved/Rejected
```

| Stage | Employee | Manager | HR Manager | HR Admin |
|-------|----------|---------|------------|----------|
| Draft | Read/Write | Read (team) | Read | Read/Write |
| Pending | Read | Read/Write | Read | Read/Write |
| Manager Approved | Read | Read | Read | Read/Write |
| HR Approved | Read | Read | Read | Read/Write |
| Rejected | Read | Read | Read | Read/Write |

### 4.2 Manager Visibility

Managers see leave requests for:
1. Direct reports (1 level down)
2. Own requests
3. Team calendar view (dates only, no reasons)

---

## 5. Calendar Visibility

### 5.1 Team Calendar

| View | Employee | Manager | HR Manager |
|------|----------|---------|------------|
| Own leaves | Full details | Full details | Full details |
| Team leaves | Dates only | Full details | Full details |
| Department | Hidden | Dates + names | Full details |

### 5.2 Confidential Leave

Certain leave types (medical, FMLA, etc.) marked as confidential:
- Only Employee, HR Manager, HR Admin see details
- Managers see only "Unavailable" on calendar

---

## 6. Family Company Considerations

### 6.1 Family Members as Employees

- Family employees see only own leave
- Manager access applies normally if family member is manager

### 6.2 Gift Flag

Holiday bonuses or leave-related gifts:
- Normal leave access by default
- With `gift_flag=true`: Only HR Admin可见

---

## 7. WordPress ESS Integration

Via ksf_WP_ESS:
- Employees view own leave balance
- Submit leave requests
- View own request status
- Cannot approve or view others' data

---

## 8. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | May 2026 | KSF Development Team | Initial specification |