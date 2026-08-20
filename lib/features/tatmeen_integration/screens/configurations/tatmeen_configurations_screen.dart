import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_configuration_body.dart';

class TatmeenConfigurationsScreen extends StatelessWidget {
  const TatmeenConfigurationsScreen({super.key, required this.canUpdate});

  final bool canUpdate;

  @override
  Widget build(BuildContext context) {
    return TatmeenConfigurationBody(
      canUpdate: canUpdate,
      selectedSection: TatmeenIntegrationSections.configurations,
    );
  }
}
