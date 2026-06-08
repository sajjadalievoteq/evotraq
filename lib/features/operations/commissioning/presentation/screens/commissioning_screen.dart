import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/screens/commissioning_desktop_split_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/screens/commissioning_operation_list_screen.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Main entry-point for the Commissioning Operations feature.
///
/// On desktop/wide layouts: split view — list left, detail right.
/// On mobile/narrow layouts: full-width list that navigates to detail via go_router.
class CommissioningScreen extends StatelessWidget {
  const CommissioningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return const CommissioningDesktopSplitScreen();
        }
        return const CommissioningOperationListScreen();
      },
    );
  }
}
