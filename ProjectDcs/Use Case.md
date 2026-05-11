# Use Cases - ksf_FA_Leave

## Reference Use Cases
- Core UC: ksf_Leave/ProjectDcs/Use Case.md (UC-LV-001 through UC-LV-012)

---

## UC-FA-LV-001: Leave GL Entries
**Actor**: System

**FA-Specific Flow**:
1. Leave approved (ksf_Workflow)
2. ksf_FA_Leave creates:
   - Monthly accrual GL entry (V01, S01, P01 liabilities)
   - Links to FA dimensions (department)
3. Liability tracked in FA GL

---

## UC-FA-LV-002: Leave Payout on Termination
**Actor**: HR, Finance

**FA-Specific Flow**:
1. Employee terminated
2. ksf_FA_Leave:
   - Calculates unused leave payout
   - Creates FA bank payment voucher
   - Posts to payroll expense

*Document Version: 1.0.0*
*Last Updated: 2026-05-11*