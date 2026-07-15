import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

void main() {
  /// Disable animations so the looping breath controller does not make
  /// [pumpAndSettle] hang indefinitely.
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

  group('AppEmptyState', () {
    testWidgets('renders empty title and fires primary action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconPackage,
            title: 'No shipping operations yet',
            subtitle: 'Create one to get started.',
            primaryActionLabel: 'Create',
            onPrimaryAction: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No shipping operations yet'), findsOneWidget);
      expect(find.text('Create one to get started.'), findsOneWidget);
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders filtered variant and fires clear filters',
        (tester) async {
      var cleared = false;
      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconPackage,
            title: 'No shipping operations yet',
            hasItems: true,
            hasActiveFilters: true,
            onClearFilters: () => cleared = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);
      await tester.tap(find.text('Clear Filters'));
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('reduced motion renders without throwing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppEmptyState(
            iconAsset: AppAssets.iconPackage,
            title: 'Empty',
            subtitle: 'Nothing here',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Empty'), findsOneWidget);
    });
  });

  group('AppEmptyDetail', () {
    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppEmptyDetail(
            title: 'Select a shipping operation',
            loading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty and fires action', (tester) async {
      var acted = false;
      await tester.pumpWidget(
        wrap(
          AppEmptyDetail(
            title: 'Select a packing operation',
            subtitle: 'Choose one from the list.',
            actionLabel: 'Refresh',
            onAction: () => acted = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Select a packing operation'), findsOneWidget);
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(acted, isTrue);
    });

    testWidgets('reduced motion detail empty renders', (tester) async {
      await tester.pumpWidget(
        wrap(const AppEmptyDetail(title: 'Select an item')),
      );
      await tester.pump();
      expect(find.text('Select an item'), findsOneWidget);
    });
  });
}
