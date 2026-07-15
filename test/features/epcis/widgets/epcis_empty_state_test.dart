import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  group('EPCIS event AppEmptyState', () {
    testWidgets('object events empty vs filtered', (tester) async {
      var cleared = false;
      var created = false;

      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconCalendar,
            title: ObjectEventListUiConstants.emptyListTitle,
            subtitle: ObjectEventListUiConstants.emptyListSubtitle,
            primaryActionLabel: ObjectEventListUiConstants.emptyAddAction,
            onPrimaryAction: () => created = true,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text(ObjectEventListUiConstants.emptyListTitle),
        findsOneWidget,
      );
      await tester.tap(find.text(ObjectEventListUiConstants.emptyAddAction));
      await tester.pump();
      expect(created, isTrue);

      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconCalendar,
            title: ObjectEventListUiConstants.emptyListTitle,
            filteredSubtitle: ObjectEventListUiConstants.emptyNoMatchSearch,
            hasItems: true,
            hasActiveFilters: true,
            onClearFilters: () => cleared = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('No results found'), findsOneWidget);
      await tester.tap(find.text('Clear Filters'));
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('aggregation events empty title', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconLayers,
            title: AggregationEventUiConstants.emptyListTitle,
            subtitle: AggregationEventUiConstants.emptyListSubtitle,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text(AggregationEventUiConstants.emptyListTitle),
        findsOneWidget,
      );
    });
  });

  group('EPCIS event AppEmptyDetail', () {
    testWidgets('object and aggregation awaiting titles', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppEmptyDetail(
            title: ObjectEventListUiConstants.awaitingSelectionTitle,
            subtitle: ObjectEventDetailUiConstants.detailAwaitingHint,
            iconAsset: AppAssets.iconCalendar,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text(ObjectEventListUiConstants.awaitingSelectionTitle),
        findsOneWidget,
      );

      await tester.pumpWidget(
        wrap(
          const AppEmptyDetail(
            title: AggregationEventUiConstants.awaitingSelectionTitle,
            subtitle: AggregationEventUiConstants.awaitingSelectionSubtitle,
            iconAsset: AppAssets.iconLayers,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text(AggregationEventUiConstants.awaitingSelectionTitle),
        findsOneWidget,
      );
    });
  });
}
