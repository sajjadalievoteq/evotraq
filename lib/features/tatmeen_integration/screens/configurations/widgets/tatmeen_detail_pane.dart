import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_dashboard.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_credentials_form.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_disabled_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_notifications_settings.dart';

part 'tatmeen_detail_content.dart';
part 'tatmeen_connection_result_banner.dart';
part 'tatmeen_connection_status_chip.dart';
part 'tatmeen_detail_skeleton.dart';

class TatmeenDetailPane extends StatelessWidget {
  const TatmeenDetailPane({
    super.key,
    required this.state,
    required this.canUpdate,
    required this.selectedSection,
    required this.onToggle,
    required this.onRetry,
    required this.onSaveCredentials,
    required this.onRemovePassword,
    required this.onRemoveApiKey,
    required this.onTestConnection,
  });

  final TatmeenIntegrationState state;
  final bool canUpdate;
  final String selectedSection;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRetry;
  final Future<bool> Function(UpdateTatmeenIntegrationSettingsRequest request)
  onSaveCredentials;
  final Future<void> Function() onRemovePassword;
  final Future<void> Function() onRemoveApiKey;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    final normalizedSection = TatmeenIntegrationSections.normalize(
      selectedSection,
    );
    if (normalizedSection == TatmeenIntegrationSections.dashboard) {
      return const TatmeenDashboard();
    }
    return switch (state.status) {
      TatmeenIntegrationStatus.initial ||
      TatmeenIntegrationStatus.loading => const TatmeenDetailSkeleton(),
      TatmeenIntegrationStatus.error => SubscriptionErrorView(
        title: 'Unable to load Tatmeen settings',
        message: state.error ?? 'Unknown error',
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      ),
      TatmeenIntegrationStatus.loaded ||
      TatmeenIntegrationStatus.updating ||
      TatmeenIntegrationStatus.testingConnection => TatmeenDetailContent(
        state: state,
        canUpdate: canUpdate,
        onToggle: onToggle,
        onSaveCredentials: onSaveCredentials,
        onRemovePassword: onRemovePassword,
        onRemoveApiKey: onRemoveApiKey,
        onTestConnection: onTestConnection,
      ),
    };
  }
}
