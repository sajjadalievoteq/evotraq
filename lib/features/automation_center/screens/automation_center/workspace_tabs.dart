import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/job_queue_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_system_health_panel.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/widgets/automation_center_tab_content.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/notification_center_screen.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/subscription_management_screen.dart';
import 'package:traqtrace_app/features/automation_center/widgets/automation_workbench_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/lazy_indexed_stack.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notifications_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

class WorkspaceTab {
  const WorkspaceTab({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final String icon;
}

class WorkspaceTabs extends StatelessWidget {
  const WorkspaceTabs({
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<WorkspaceTab> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            Semantics(
              button: true,
              selected: tab.id == selectedId,
              child: InkWell(
                onTap: () => onSelected(tab.id),
                borderRadius: TraqRadius.button,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TraqSpacing.lg,
                    vertical: TraqSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: tab.id == selectedId
                            ? colors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(
                        tab.icon,
                        size: 16,
                        color: tab.id == selectedId
                            ? colors.primary
                            : colors.textMuted,
                      ),
                      const SizedBox(width: TraqSpacing.sm),
                      Text(
                        tab.label,
                        style: context.text.bodySm.copyWith(
                          color: tab.id == selectedId
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: tab.id == selectedId
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
