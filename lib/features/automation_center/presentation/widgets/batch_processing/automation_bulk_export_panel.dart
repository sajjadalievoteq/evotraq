import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_export_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationBulkExportPanel extends StatelessWidget {
  const AutomationBulkExportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkbenchPanelShell(
      title: 'Bulk Export',
      slice: const WorkbenchSlice(),
      expandBody: true,
      child: BulkExportPanel(
        baseUrl: getIt<AppConfig>().apiBaseUrl,
        tokenManager: getIt<TokenManager>(),
      ),
    );
  }
}
