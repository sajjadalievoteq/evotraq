
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

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
  if (isCreating) return true;
  return status == LogisticUnitStatus.DRAFT;
}

bool canDeleteSscc(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DRAFT;
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
