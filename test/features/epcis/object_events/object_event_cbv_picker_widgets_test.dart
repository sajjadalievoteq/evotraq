import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/cbv_biz_step_disposition_picker.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_biz_step_dropdown.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_disposition_dropdown.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_field_skeleton.dart';

void main() {
  test('CBV picker component types remain independently available', () {
    expect(CbvBizStepDispositionPicker, isNotNull);
    expect(ObjectEventCbvBizStepDropdown, isNotNull);
    expect(ObjectEventCbvDispositionDropdown, isNotNull);
  });

  testWidgets('CBV field skeleton preserves its field height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ObjectEventCbvFieldSkeleton())),
    );

    expect(tester.getSize(find.byType(Container)).height, 50);
  });
}
