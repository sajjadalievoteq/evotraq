import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance_widget.dart';
import 'package:traqtrace_app/core/animation/traq_stagger_item.dart';

void main() {
  testWidgets('staggered entrance does not play while tickers are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TickerMode(
        enabled: false,
        child: MaterialApp(
          home: Scaffold(
            body: TraqStaggeredEntrance(
              children: [Text('first'), Text('second')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final fades = tester.widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(TraqStaggeredEntrance),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fades, isNotEmpty);
    expect(fades.every((fade) => fade.opacity.value == 0), isTrue);
  });

  testWidgets('staggered entrance plays after the first painted frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TraqStaggeredEntrance(
            children: [Text('first'), Text('second')],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.byType(TraqStaggerItem), findsNWidgets(2));
  });
}
