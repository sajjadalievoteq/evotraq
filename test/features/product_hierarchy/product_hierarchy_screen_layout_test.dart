import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/product_journey/product_journey_service.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/product_hierarchy_screen.dart';

class _MockHierarchyService extends Mock implements HierarchyService {}

class _MockJourneyService extends Mock implements ProductJourneyService {}

void main() {
  
  setUp(() {
    getIt.registerFactory<HierarchyService>(() => _MockHierarchyService());
    getIt.registerFactory<ProductJourneyService>(() => _MockJourneyService());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'builds on a narrow layout without unbounded-height layout errors',
    (tester) async {
      
      
      
      
      
      tester.view.physicalSize = const Size(420, 900);
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

      expect(tester.takeException(), isNull);
    },
  );
}
