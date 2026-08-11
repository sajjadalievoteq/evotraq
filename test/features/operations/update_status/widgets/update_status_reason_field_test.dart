import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/widgets/update_status_reason_field.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('uses free-text reason for ordinary dispositions', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        UpdateStatusReasonField(
          selectedDisposition: UpdateStatusDisposition.lost,
          reasonController: controller,
          selectedReason: null,
          onReasonChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('freetext-reason')), findsOneWidget);
    expect(find.text('Reason (optional)'), findsOneWidget);
  });

  testWidgets('uses sample-reason dropdown for sample disposition', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        UpdateStatusReasonField(
          selectedDisposition: UpdateStatusDisposition.sample,
          reasonController: controller,
          selectedReason: null,
          onReasonChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sample-reason')), findsOneWidget);
    expect(find.text('Select a sample reason'), findsOneWidget);
  });
}
