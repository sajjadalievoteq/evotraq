import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_field_skeleton.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_picker.dart';

void main() {
  test('aggregation CBV component types remain independently available', () {
    expect(AggregationCbvPicker, isNotNull);
    expect(AggregationCbvDropdownField, isNotNull);
  });

  testWidgets('aggregation CBV skeleton preserves its original height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AggregationCbvFieldSkeleton())),
    );

    expect(tester.getSize(find.byType(Container)).height, 56);
  });
}
