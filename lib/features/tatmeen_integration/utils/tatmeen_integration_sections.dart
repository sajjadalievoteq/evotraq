import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

abstract final class TatmeenIntegrationSections {
  static const integration = 'integration';
  static const credentials = 'credentials';

  static const groups = [
    WorkbenchRailGroup(
      title: 'Tatmeen',
      items: [
        WorkbenchRailItem(
          id: integration,
          iconAsset: NavIcons.tatmeenIntegration,
          label: 'Integration',
        ),
      ],
    ),
  ];

  static String normalize(String? section) {
    if (section == null || section.trim().isEmpty) return integration;
    return switch (section) {
      integration => integration,
      credentials => credentials,
      _ => integration,
    };
  }
}
