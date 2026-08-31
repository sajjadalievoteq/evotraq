import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'    as status_rules;

bool canEditSsccRecord(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DRAFT ||
      status == LogisticUnitStatus.ALLOCATED;
}

bool isSsccIdentityLocked(LogisticUnitStatus status) {
  return status != LogisticUnitStatus.DRAFT;
}

bool canManuallyEditSsccStatus(
  LogisticUnitStatus status, {
  bool isCreating = false,
}) {
  // Create always persists ALLOCATED (or explicit draft via dedicated draft flows).
  // Users must not pick ACTIVE / IN_TRANSIT / etc. on create.
  if (isCreating) return false;
  return status == LogisticUnitStatus.DRAFT;
}

bool canDeleteSscc(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DRAFT;
}

bool canCommissionSsccRecord(LogisticUnitStatus status, {SSCC? sscc}) {
  if (status != LogisticUnitStatus.ALLOCATED) return false;
  if (sscc == null) return true;
  if (sscc.commissionedAt != null) return false;
  final eventId = sscc.commissioningEventId;
  return eventId == null || eventId.isEmpty;
}

bool isSsccAggregationEditable({required bool isCreating}) => isCreating;

const String statusEventDrivenHint =
    'Lifecycle status is updated by commissioning, shipping, and receiving events.';

String readOnlyLifecycleMessage(LogisticUnitStatus status) {
  if (status_rules.isTerminal(status)) {
    return 'This SSCC is ${status_rules.friendlyLabel(status)} and cannot be edited.';
  }
  if (!canEditSsccRecord(status)) {
    return 'SSCC master data is read-only after commissioning. '
        'Lifecycle changes are driven by EPCIS events.';
  }
  return 'This SSCC cannot be edited.';
}
