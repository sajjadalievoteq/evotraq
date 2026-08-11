import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/widgets/transformation_event_list_item.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_events_list/widgets/transformation_events_quick_info_card.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('quick-info card preserves learn-more callback', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(TransformationEventsQuickInfoCard(onLearnMore: () => calls++)),
    );

    expect(find.text('GS1 Transformation Events'), findsOneWidget);
    await tester.tap(find.text('Learn More'));
    expect(calls, 1);
  });

  testWidgets('event item preserves counts, identifier, and tap callback', (
    tester,
  ) async {
    var calls = 0;
    final eventTime = DateTime(2026, 8, 11, 9, 30);
    final event = TransformationEvent(
      eventId: 'event-1',
      eventTime: eventTime,
      recordTime: eventTime,
      eventTimeZoneOffset: '+04:00',
      transformationID: 'transform-1',
      inputEPCList: const ['input-1', 'input-2'],
      outputEPCList: const ['output-1'],
    );

    await tester.pumpWidget(
      _host(TransformationEventListItem(event: event, onTap: () => calls++)),
    );

    expect(find.text('ID: transform-1'), findsOneWidget);
    expect(find.text('2 input(s) → 1 output(s)'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    expect(calls, 1);
  });
}
