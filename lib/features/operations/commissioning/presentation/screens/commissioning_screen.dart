import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/screens/commissioning_desktop_split_screen.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/screens/commissioning_operation_list_screen.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

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
