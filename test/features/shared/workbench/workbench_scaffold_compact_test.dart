import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

void main() {
  const groups = [
    WorkbenchRailGroup(
      title: 'Tools',
      items: [
        WorkbenchRailItem(
          id: 'convert',
          iconAsset: AppAssets.iconSearch,
          label: 'Convert',
        ),
        WorkbenchRailItem(
          id: 'validate',
          iconAsset: AppAssets.iconSearch,
          label: 'Validate',
        ),
      ],
    ),
  ];

  testWidgets(
    'compact workbench section dropdown lays out without unbounded width',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: WorkbenchScaffold(
            title: 'GS1 Tools',
            groups: groups,
            selectedId: 'convert',
            onSelect: (_) {},
            panelBuilder: (_, id) => Text('panel-$id'),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Convert'), findsWidgets);
    },
  );
}
