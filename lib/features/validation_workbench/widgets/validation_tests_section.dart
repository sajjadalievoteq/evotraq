import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/gs1_validation_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class ValidationTestsSection extends StatelessWidget {
  const ValidationTestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkbenchPanelShell(
      title: 'Batch Validation',
      slice: WorkbenchSlice(),
      expandBody: true,
      child: GS1ValidationScreen(embedded: true),
    );
  }
}
