import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart';

void main() {
  test('create flow does not allow picking ACTIVE or later statuses', () {
    expect(
      canManuallyEditSsccStatus(LogisticUnitStatus.ALLOCATED, isCreating: true),
      isFalse,
    );
  });

  test('draft records can still be allocated via status endpoint rules', () {
    expect(
      canManuallyEditSsccStatus(LogisticUnitStatus.DRAFT, isCreating: false),
      isTrue,
    );
    expect(
      canTransition(LogisticUnitStatus.DRAFT, LogisticUnitStatus.ALLOCATED),
      isTrue,
    );
    expect(
      canTransition(LogisticUnitStatus.DRAFT, LogisticUnitStatus.ACTIVE),
      isFalse,
    );
    expect(
      canTransition(LogisticUnitStatus.ALLOCATED, LogisticUnitStatus.ACTIVE),
      isTrue,
    );
  });
}
