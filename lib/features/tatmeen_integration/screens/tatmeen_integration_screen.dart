import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_cubit.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_integration_body.dart';

class TatmeenIntegrationScreen extends StatefulWidget {
  const TatmeenIntegrationScreen({super.key});

  @override
  State<TatmeenIntegrationScreen> createState() =>
      _TatmeenIntegrationScreenState();
}

class _TatmeenIntegrationScreenState extends State<TatmeenIntegrationScreen> {
  late final TatmeenIntegrationCubit _cubit;
  late String _selectedSection;
  bool? _lastKnownEnabled;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TatmeenIntegrationCubit>()..load();
    _selectedSection = TatmeenIntegrationSections.integration;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUpdate = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<TatmeenIntegrationCubit, TatmeenIntegrationState>(
        listenWhen: (previous, current) {
          if (current.error != null && current.error != previous.error) {
            return true;
          }
          if (previous.status == TatmeenIntegrationStatus.updating &&
              current.status == TatmeenIntegrationStatus.loaded &&
              current.error == null &&
              _lastKnownEnabled != null &&
              current.isEnabled != _lastKnownEnabled) {
            return true;
          }
          if (previous.status == TatmeenIntegrationStatus.updating &&
              current.status == TatmeenIntegrationStatus.loaded &&
              current.error == null &&
              previous.settings != current.settings &&
              previous.isEnabled == current.isEnabled) {
            return true;
          }
          if (previous.status == TatmeenIntegrationStatus.testingConnection &&
              current.status == TatmeenIntegrationStatus.loaded &&
              current.connectionTestResult != null) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state.error != null) {
            context.showError(state.error!);
            return;
          }
          if (_lastKnownEnabled != null &&
              state.isEnabled != _lastKnownEnabled) {
            context.showSuccess(
              state.isEnabled
                  ? 'Tatmeen Integration enabled'
                  : 'Tatmeen Integration disabled',
            );
            return;
          }
          if (state.connectionTestResult != null) {
            final result = state.connectionTestResult!;
            if (result.success) {
              context.showSuccess(result.message);
            } else {
              context.showError(result.message);
            }
            return;
          }
          if (state.status == TatmeenIntegrationStatus.loaded &&
              state.settings != null) {
            context.showSuccess('Tatmeen credentials saved');
          }
        },
        child: BlocListener<TatmeenIntegrationCubit, TatmeenIntegrationState>(
          listenWhen: (previous, current) =>
              current.status == TatmeenIntegrationStatus.updating &&
              previous.status != TatmeenIntegrationStatus.updating,
          listener: (context, state) {
            _lastKnownEnabled = state.confirmedEnabled;
          },
          child: WorkbenchScaffold(
            title: 'Tatmeen Integration',
            groups: TatmeenIntegrationSections.groups,
            selectedId: _selectedSection,
            onSelect: (id) => setState(
              () => _selectedSection = TatmeenIntegrationSections.normalize(id),
            ),
            panelBuilder: (context, _) => AutomationWorkbenchPanel(
              title: 'Tatmeen Integration',
              fillBody: true,
              child: TatmeenIntegrationBody(
                canUpdate: canUpdate,
                selectedSection: _selectedSection,
                onSelectSection: (id) => setState(
                  () => _selectedSection = TatmeenIntegrationSections.normalize(
                    id,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
