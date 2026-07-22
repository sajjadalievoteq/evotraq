import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_page.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_left_panel.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_tree_panel.dart';

class _MockHierarchyService extends Mock implements HierarchyService {}

class _MockJourneyService extends Mock implements ProductJourneyService {}

void main() {
  group('Product hierarchy widgets', () {
    late _MockHierarchyService hierarchyService;
    late _MockJourneyService journeyService;
    late ProductHierarchyCubit cubit;

    const root = 'urn:epc:id:sscc:0614141.1234567890';
    const child = 'urn:epc:id:sscc:0614141.1234567891';
    const leaf = 'urn:epc:id:sgtin:0614141.107346.SN1001';

    setUp(() {
      hierarchyService = _MockHierarchyService();
      journeyService = _MockJourneyService();
      cubit = ProductHierarchyCubit(
        hierarchyService: hierarchyService,
        journeyService: journeyService,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('renders details + root, expands children lazily', (
      tester,
    ) async {
      when(
        () => hierarchyService.getRootContainer(any()),
      ).thenAnswer((_) async => root);
      when(
        () => hierarchyService.getHierarchyChildren(
          root,
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => const HierarchyPage(
          children: [
            HierarchyNode(
              epc: child,
              type: 'SSCC',
              hasChildren: true,
              childCount: 1,
            ),
          ],
          page: 0,
          size: 20,
          total: 1,
          totalPages: 1,
          hasMore: false,
        ),
      );
      when(
        () => hierarchyService.getHierarchyChildren(
          child,
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => const HierarchyPage(
          children: [
            HierarchyNode(
              epc: leaf,
              type: 'SGTIN',
              hasChildren: false,
              childCount: 0,
            ),
          ],
          page: 0,
          size: 20,
          total: 1,
          totalPages: 1,
          hasMore: false,
        ),
      );
      when(() => journeyService.getJourneyByIdentifier(any())).thenAnswer(
        (_) async => const ProductJourney(
          identifier: root,
          identifierType: 'SSCC',
          steps: [],
        ),
      );
      when(
        () => journeyService.searchProducts(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: BlocProvider.value(
            value: cubit,
            child: Row(
              children: [
                Expanded(
                  child: ProductHierarchyLeftPanel(
                    searchController: TextEditingController(text: root),
                  ),
                ),
                const VerticalDivider(),
                const Expanded(child: ProductHierarchyTreePanel()),
              ],
            ),
          ),
        ),
      );

      await cubit.openHierarchy(root);
      await tester.pumpAndSettle();

      expect(cubit.state.selectedJourney, isNotNull);
      expect(cubit.state.root?.isExpanded, isFalse);
      expect(find.text(root), findsWidgets);
      expect(find.text(child), findsNothing);

      
      await tester.tap(find.text(root).last);
      await tester.pumpAndSettle();
      expect(cubit.state.root?.isExpanded, isTrue);
      expect(find.text(child), findsOneWidget);

      await tester.tap(find.text(child));
      await tester.pumpAndSettle();

      verify(
        () => hierarchyService.getHierarchyChildren(
          child,
          page: 0,
          size: any(named: 'size'),
        ),
      ).called(1);
      expect(find.text(leaf), findsOneWidget);
    });
  });
}
