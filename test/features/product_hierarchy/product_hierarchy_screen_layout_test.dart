import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/product_hierarchy_screen.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_compact_body.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';

class _MockHierarchyService extends Mock implements HierarchyService {}

class _MockJourneyService extends Mock implements ProductJourneyService {}

class _MockPackingService extends Mock implements PackingOperationService {}

void main() {
  late _MockPackingService packingService;

  setUp(() {
    packingService = _MockPackingService();
    when(
      () => packingService.getAllPackingOperations(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => []);
    getIt.registerFactory<HierarchyService>(() => _MockHierarchyService());
    getIt.registerFactory<ProductJourneyService>(() => _MockJourneyService());
    getIt.registerFactory<PackingOperationService>(() => packingService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: TraqTheme.light(),
        home: const ProductHierarchyScreen(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'builds on a narrow layout without unbounded-height layout errors',
    (tester) async {
      await pumpScreen(tester, const Size(420, 900));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phone and tablet compact body shows the list without the tree',
    (tester) async {
      await pumpScreen(tester, const Size(420, 900));

      final compact = find.byType(ProductHierarchyCompactBody);
      expect(compact, findsOneWidget);
      expect(
        find.descendant(
          of: compact,
          matching: find.byType(ProductHierarchyLeftPanel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: compact,
          matching: find.byType(DraggableScrollableSheet),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('tablet medium width also stays list-first', (tester) async {
    await pumpScreen(tester, const Size(800, 1024));

    expect(
      find.descendant(
        of: find.byType(ProductHierarchyCompactBody),
        matching: find.byType(ProductHierarchyTreePanel),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(ProductHierarchyCompactBody),
        matching: find.byType(ProductHierarchyLeftPanel),
      ),
      findsOneWidget,
    );
  });

  testWidgets('desktop keeps the side-by-side list and tree', (tester) async {
    await pumpScreen(tester, const Size(1400, 900));

    expect(find.byType(MasterDetailSplitLayout), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MasterDetailSplitLayout),
        matching: find.byType(ProductHierarchyLeftPanel),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(MasterDetailSplitLayout),
        matching: find.byType(DraggableScrollableSheet),
      ),
      findsNothing,
    );
  });
}
