import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/admin/widgets/etl_management_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationEtlPanel extends StatelessWidget {
  const AutomationEtlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkbenchPanelShell(
      title: 'ETL',
      slice: const WorkbenchSlice(),
      expandBody: true,
      child: ETLManagementPanel(
        baseUrl: getIt<AppConfig>().apiBaseUrl,
        tokenManager: getIt<TokenManager>(),
      ),
    );
  }
}
