import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/inbound_catalog_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_shape.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: TraqTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('managementMasterDetail uses side-by-side layout when wide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 1200,
          height: 600,
          child: SubscriptionLoadingSkeleton(
            shrinkWrap: true,
            shape: SubscriptionSkeletonShape.managementMasterDetail,
          ),
        ),
      ),
    );

    expect(find.byType(Row), findsWidgets);
    // Stacked Column with fixed list height is not used on wide layouts.
    expect(
      find.byWidgetPredicate((w) => w is SizedBox && w.height == 220),
      findsNothing,
    );
  });

  testWidgets('managementMasterDetail stacks when narrow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(700, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 700,
          height: 600,
          child: SubscriptionLoadingSkeleton(
            shrinkWrap: true,
            shape: SubscriptionSkeletonShape.managementMasterDetail,
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate((w) => w is SizedBox && w.height == 220),
      findsOneWidget,
    );
  });

  testWidgets('managementMasterDetail layouts in unbounded height when wide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        ListView(
          children: const [
            SubscriptionLoadingSkeleton(
              shrinkWrap: true,
              shape: SubscriptionSkeletonShape.managementMasterDetail,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'managementMasterDetail layouts in unbounded height when stacked',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrap(
          ListView(
            children: const [
              SubscriptionLoadingSkeleton(
                shrinkWrap: true,
                shape: SubscriptionSkeletonShape.managementMasterDetail,
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('activityCard layouts in unbounded height when shrinkWrap', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ListView(
          children: const [
            SubscriptionLoadingSkeleton(
              shrinkWrap: true,
              itemCount: 3,
              shape: SubscriptionSkeletonShape.activityCard,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('inbound catalog skeleton renders a category grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const InboundCatalogLoadingSkeleton(tileCount: 5)),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(5));
  });
}
