import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_cubit.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_configuration_confirm_dialogs.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/widgets/tatmeen_detail_pane.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';

class TatmeenConfigurationBody extends StatelessWidget {
  const TatmeenConfigurationBody({
    super.key,
    required this.canUpdate,
    required this.selectedSection,
  });

  final bool canUpdate;
  final String selectedSection;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TatmeenIntegrationCubit, TatmeenIntegrationState>(
      builder: (context, state) {
        final cubit = context.read<TatmeenIntegrationCubit>();
        return TatmeenDetailPane(
          state: state,
          canUpdate: canUpdate,
          selectedSection: TatmeenIntegrationSections.normalize(
            selectedSection,
          ),
          onToggle: (enabled) => _handleToggle(context, cubit, enabled),
          onRetry: () => cubit.load(force: true),
          onSaveCredentials: (request) => _handleSave(context, cubit, request),
          onRemovePassword: () => _handleRemovePassword(context, cubit),
          onRemoveApiKey: () => _handleRemoveApiKey(context, cubit),
          onTestConnection: () => cubit.testConnection(),
        );
      },
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    TatmeenIntegrationCubit cubit,
    bool enabled,
  ) async {
    final confirmed = enabled
        ? await showTatmeenEnableConfirmDialog(context)
        : await showTatmeenDisableConfirmDialog(context);
    if (!confirmed) return;
    await cubit.setEnabled(enabled);
  }

  Future<bool> _handleSave(
    BuildContext context,
    TatmeenIntegrationCubit cubit,
    UpdateTatmeenIntegrationSettingsRequest request,
  ) async {
    await cubit.saveSettings(request);
    return cubit.state.error == null;
  }

  Future<void> _handleRemovePassword(
    BuildContext context,
    TatmeenIntegrationCubit cubit,
  ) async {
    final confirmed = await showTatmeenRemoveCredentialDialog(
      context,
      credentialLabel: 'password',
    );
    if (!confirmed) return;
    await cubit.saveSettings(
      const UpdateTatmeenIntegrationSettingsRequest(clearPassword: true),
    );
  }

  Future<void> _handleRemoveApiKey(
    BuildContext context,
    TatmeenIntegrationCubit cubit,
  ) async {
    final confirmed = await showTatmeenRemoveCredentialDialog(
      context,
      credentialLabel: 'API key',
    );
    if (!confirmed) return;
    await cubit.saveSettings(
      const UpdateTatmeenIntegrationSettingsRequest(clearApiKey: true),
    );
  }
}
