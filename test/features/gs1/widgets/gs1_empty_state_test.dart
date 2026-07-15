import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

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

  group('GS1 AppEmptyState list copy', () {
    testWidgets('GTIN empty vs filtered variants', (tester) async {
      var cleared = false;
      var created = false;

      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconQr,
            title: GtinUiConstants.emptyListTitle,
            subtitle: GtinUiConstants.emptyListSubtitle,
            primaryActionLabel: GtinUiConstants.emptyAddAction,
            onPrimaryAction: () => created = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text(GtinUiConstants.emptyListTitle), findsOneWidget);
      await tester.tap(find.text(GtinUiConstants.emptyAddAction));
      await tester.pump();
      expect(created, isTrue);

      await tester.pumpWidget(
        wrap(
          AppEmptyState(
            iconAsset: AppAssets.iconQr,
            title: GtinUiConstants.emptyListTitle,
            filteredSubtitle: GtinUiConstants.emptyNoMatchSearch,
            hasItems: true,
            hasActiveFilters: true,
            onClearFilters: () => cleared = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('No results found'), findsOneWidget);
      expect(find.text(GtinUiConstants.emptyNoMatchSearch), findsOneWidget);
      await tester.tap(find.text('Clear Filters'));
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('GLN / SGTIN / SSCC empty titles render', (tester) async {
      for (final title in [
        GlnUiConstants.emptyListTitle,
        SgtinUiConstants.emptyListTitle,
        SsccUiConstants.emptyListTitle,
      ]) {
        await tester.pumpWidget(
          wrap(
            AppEmptyState(
              iconAsset: AppAssets.iconPackage,
              title: title,
              subtitle: 'Create one to get started.',
            ),
          ),
        );
        await tester.pump();
        expect(find.text(title), findsOneWidget);
      }
    });
  });

  group('GS1 AppEmptyDetail awaiting selection', () {
    testWidgets('renders per-type titles and loading', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppEmptyDetail(
            title: GtinUiConstants.awaitingSelectionTitle,
            subtitle: GtinUiConstants.awaitingSelectionSubtitle,
            iconAsset: AppAssets.iconQr,
          ),
        ),
      );
      await tester.pump();
      expect(find.text(GtinUiConstants.awaitingSelectionTitle), findsOneWidget);

      await tester.pumpWidget(
        wrap(
          const AppEmptyDetail(
            title: SsccUiConstants.awaitingSelectionTitle,
            loading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
