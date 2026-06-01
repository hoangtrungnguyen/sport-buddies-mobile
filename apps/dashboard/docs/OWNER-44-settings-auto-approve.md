# OWNER-44 · Settings — Auto-approve for single-time bookings

## Acceptance Criteria vs Implementation

| # | Criterion | Status | Implementation |
|---|---|---|---|
| 1 | "Cài đặt" entry in sidebar below Analytics; route `/settings` | ✅ | `app_shell.dart` — `_systemNav` entry with `route: '/settings'`, rendered below `_mainNav` which ends with Analytics |
| 2 | "Tự động duyệt đặt sân một lần" section + on/off toggle, defaulting to off | ✅ | `_AutoApproveSection` in `settings_screen.dart`; `OwnerCourt.autoApproveSingle` defaults to `false` |
| 3 | Toggle label reflects current state | ✅ | `_AutoApproveToggle` shows "Đang bật" / "Đang tắt" based on `court.autoApproveSingle` |
| 4 | Helper text: "Chỉ áp dụng cho đặt sân một lần. Lịch cố định vẫn cần duyệt thủ công." | ✅ | `settings_screen.dart:421` |
| 5 | Saving calls PATCH `/courts/:id/settings`; `courts.auto_approve_single` in Supabase | ✅ | `OwnerCourtRepository.updateAutoApprove()` → `.update({'auto_approve_single': value}).eq('id', courtId)` |
| 6 | Per-court; court selector scopes toggle for multi-court owners | ✅ | `DropdownButton` shown when `courts.length > 1`; `_selectedCourtId` state in `_AutoApproveSectionState` |
| 7 | Persisted immediately (no Save button); snackbar "Đã lưu cài đặt" | ✅ | Optimistic update in `CourtBloc`; snackbar text fixed to "Đã lưu cài đặt" |
| 8 | RLS: only role=owner with `courts.owner_id = auth.uid()` | ✅ | Column-level RLS enforced at migration 0003; row policy scopes to `owner_id = auth.uid()` |

## Key Files

| File | Role |
|---|---|
| `lib/features/settings/view/settings_screen.dart` | UI — `_AutoApproveSection`, `_AutoApproveToggle` |
| `lib/features/setup/bloc/court_bloc.dart` | `CourtAutoApproveToggled` handler — optimistic update + revert on failure |
| `lib/features/setup/bloc/court_event.dart` | `autoApproveToggled(String courtId, {required bool value})` |
| `lib/features/setup/model/owner_court.dart` | `autoApproveSingle` field — JSON key `auto_approve_single`, default `false` |
| `lib/features/setup/repository/owner_court_repository.dart` | `updateAutoApprove()` — Supabase PATCH |
| `lib/core/router/app_router.dart` | `/settings` route — provides `CourtBloc` + fires `loadRequested` on entry |
| `lib/shell/app_shell.dart` | Sidebar nav entry in `_systemNav` |
