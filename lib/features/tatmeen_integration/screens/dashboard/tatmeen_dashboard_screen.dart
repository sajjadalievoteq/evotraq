import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/lazy_indexed_stack.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_cubit.dart';
import 'package:traqtrace_app/features/tatmeen_integration/cubit/tatmeen_integration_state.dart';
import 'package:traqtrace_app/features/tatmeen_integration/data/tatmeen_dummy_sync_data.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_dashboard.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_navigation.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/tatmeen_view_stack.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/tatmeen_view_stack_scope.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/configurations/tatmeen_configurations_screen.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/tatmeen_records_screen.dart';
import 'package:traqtrace_app/features/tatmeen_integration/utils/tatmeen_integration_sections.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_dashboard.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_failed_queue_pane.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_logs_pane.dart';

class TatmeenDashboardScreen extends StatefulWidget {
  const TatmeenDashboardScreen({super.key});

  @override
  State<TatmeenDashboardScreen> createState() => _TatmeenDashboardScreenState();
}

class _TatmeenDashboardScreenState extends State<TatmeenDashboardScreen> {
  late final TatmeenIntegrationCubit _cubit;
  late final UseTatmeenDashboard _dashboard;
  late final TatmeenViewStack _viewStack;
  late String _selectedSection;
  bool? _lastKnownEnabled;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TatmeenIntegrationCubit>()..load();
    _dashboard = UseTatmeenDashboard(
      service: getIt<TatmeenIntegrationService>(),
    )..load();
    _viewStack = TatmeenViewStack(
      initialView: TatmeenIntegrationSections.dashboard,
    );
    _selectedSection = TatmeenIntegrationSections.dashboard;
  }

  @override
  void dispose() {
    _dashboard.dispose();
    _viewStack.dispose();
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
          child: TatmeenViewStackScope(
            stack: _viewStack,
            child: WorkbenchScaffold(
              title: 'Tatmeen Integration',
              groups: TatmeenIntegrationSections.groups(
                failedQueueCount: TatmeenDummySyncData.failedQueue().length,
              ),
              selectedId: _selectedSection,
              onSelect: (id) {
                final section = TatmeenIntegrationSections.normalize(id);
                setState(() => _selectedSection = section);
                _viewStack.resetTo(section);
              },
              panelBuilder: (context, selectedId) {
                final section = TatmeenIntegrationSections.normalize(
                  selectedId,
                );
                return AnimatedBuilder(
                  animation: _viewStack,
                  builder: (context, _) {
                    final showingRecords =
                        _viewStack.current.view ==
                        TatmeenNavigation.recordsView;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Offstage(
                          offstage: showingRecords,
                          child: LazyIndexedStack(
                            index: TatmeenIntegrationSections.indexOf(section),
                            sizing: StackFit.expand,
                            children: [
                              TatmeenDashboard(controller: _dashboard),
                              AutomationWorkbenchPanel(
                                title: TatmeenIntegrationSections.panelTitle(
                                  TatmeenIntegrationSections.configurations,
                                ),
                                child: TatmeenConfigurationsScreen(
                                  canUpdate: canUpdate,
                                ),
                              ),
                              AutomationWorkbenchPanel(
                                title: TatmeenIntegrationSections.panelTitle(
                                  TatmeenIntegrationSections.failedQueue,
                                ),
                                child: const TatmeenFailedQueuePane(),
                              ),
                              AutomationWorkbenchPanel(
                                title: TatmeenIntegrationSections.panelTitle(
                                  TatmeenIntegrationSections.syncLogs,
                                ),
                                child: const TatmeenSyncLogsPane(),
                              ),
                            ],
                          ),
                        ),
                        if (showingRecords)
                          TatmeenRecordsScreen(
                            filter: RecordsFilter.fromExtra(
                              _viewStack.current.params['filter'],
                            ),
                            embedded: true,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
