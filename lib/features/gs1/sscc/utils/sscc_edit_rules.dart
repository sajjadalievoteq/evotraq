/// Spec-aligned SSCC master-data editability (documentation/_sscc_spec_extracted.txt).
///
/// Identity fields lock at ALLOCATED; lifecycle after that is EPCIS-event-driven.

import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

/// Pre-commission records only (DRAFT, ALLOCATED).
bool canEditSsccRecord(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DRAFT ||
      status == LogisticUnitStatus.ALLOCATED;
}

/// SSCC code and extension digit are editable only while DRAFT.
bool isSsccIdentityLocked(LogisticUnitStatus status) {
  return status != LogisticUnitStatus.DRAFT;
}

/// Manual status dropdown: DRAFT → ALLOCATED / VOIDED only.
bool canManuallyEditSsccStatus(
  LogisticUnitStatus status, {
  bool isCreating = false,
}) {
  if (isCreating) return true;
  return status == LogisticUnitStatus.DRAFT;
}

/// Hard delete allowed only for drafts (spec: no delete within non-reuse window).
bool canDeleteSscc(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DRAFT;
}

/// Aggregation tree is maintained via EPCIS AggregationEvents, not master-data forms.
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
