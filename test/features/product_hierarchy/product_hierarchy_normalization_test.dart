import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_page.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';

class _MockHierarchyService extends Mock implements HierarchyService {}

class _MockJourneyService extends Mock implements ProductJourneyService {}

void main() {
  group('Product hierarchy input normalization', () {
    test('Digital Link / URN / SSCC-18 resolve same root', () async {
      final hierarchyService = _MockHierarchyService();
      final journeyService = _MockJourneyService();
      final cubit = ProductHierarchyCubit(
        hierarchyService: hierarchyService,
        journeyService: journeyService,
      );

      const canonicalRoot = 'urn:epc:id:sscc:0614141.1234567890';
      when(
        () => hierarchyService.getRootContainer(any()),
      ).thenAnswer((_) async => canonicalRoot);
      when(
        () => hierarchyService.getHierarchyChildren(
          any(),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => const HierarchyPage(
          children: [],
          page: 0,
          size: 20,
          total: 0,
          totalPages: 0,
          hasMore: false,
        ),
      );
      when(
        () => journeyService.getJourneyByIdentifier(any()),
      ).thenAnswer((_) async => null);

      await cubit.openHierarchy('https://id.gs1.org/00/006141411234567890');
      expect(cubit.state.root?.node.epc, canonicalRoot);

      await cubit.openHierarchy('urn:epc:id:sscc:0614141.1234567890');
      expect(cubit.state.root?.node.epc, canonicalRoot);

      await cubit.openHierarchy('006141411234567890');
      expect(cubit.state.root?.node.epc, canonicalRoot);

      await cubit.close();
    });
  });
}
