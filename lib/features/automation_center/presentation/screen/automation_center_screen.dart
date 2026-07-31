import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/automation_center/presentation/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/batch_processing/automation_bulk_export_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/batch_processing/automation_bulk_import_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/batch_processing/automation_etl_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/batch_processing/automation_job_queue_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/notifications/automation_statistics_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/notifications/automation_subscriptions_panel.dart';
import 'package:traqtrace_app/features/automation_center/presentation/widgets/notifications/automation_webhook_history_panel.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/notifications/presentation/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

class AutomationCenterScreen extends StatelessWidget {
  const AutomationCenterScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  Widget build(BuildContext context) {
    return NotificationsShell(
      child: _AutomationCenterView(initialSection: initialSection),
    );
  }
}

class _AutomationCenterView extends StatefulWidget {
  const _AutomationCenterView({this.initialSection});

  final String? initialSection;

  @override
  State<_AutomationCenterView> createState() => _AutomationCenterViewState();
}

class _AutomationCenterViewState extends State<_AutomationCenterView> {
  late String _selectedSection;
  late final Set<String> _visitedSections;

  @override
  void initState() {
    super.initState();
    _selectedSection = AutomationCenterSections.normalize(
      widget.initialSection,
    );
    _visitedSections = {_selectedSection};
  }

  @override
  void didUpdateWidget(_AutomationCenterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = AutomationCenterSections.normalize(widget.initialSection);
    if (next != _selectedSection) {
      setState(() {
        _selectedSection = next;
        _visitedSections.add(next);
      });
    }
  }

  void _selectSection(String section) {
    final next = AutomationCenterSections.normalize(section);
    if (next == _selectedSection) return;
    setState(() {
      _selectedSection = next;
      _visitedSections.add(next);
    });
    context.go(AutomationCenterSections.location(next));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );
    return Title(
      title: 'Automation Center',
      color: Colors.white,
      child: WorkbenchScaffold(
        title: 'Automation Center',
        groups: AutomationCenterSections.groupsFor(isAdmin: isAdmin),
        selectedId: _selectedSection,
        onSelect: _selectSection,
        panelBuilder: (context, selectedId) {
          return IndexedStack(
            index: AutomationCenterSections.indexOf(selectedId),
            children: [
              _lazyPanel(
                AutomationCenterSections.subscriptions,
                const AutomationSubscriptionsPanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.webhookHistory,
                const AutomationWebhookHistoryPanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.statistics,
                const AutomationStatisticsPanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.jobQueue,
                const AutomationJobQueuePanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.bulkImport,
                const AutomationBulkImportPanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.bulkExport,
                const AutomationBulkExportPanel(),
              ),
              _lazyPanel(
                AutomationCenterSections.etl,
                const AutomationEtlPanel(),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _lazyPanel(String section, Widget panel) {
    return _visitedSections.contains(section)
        ? KeyedSubtree(key: ValueKey(section), child: panel)
        : const SizedBox.shrink();
  }
}
