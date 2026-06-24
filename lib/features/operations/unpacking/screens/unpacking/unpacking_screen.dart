import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_desktop_split/unpacking_desktop_split_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/unpacking_operation_list_screen.dart';

class UnpackingScreen extends StatelessWidget {
  const UnpackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return const UnpackingDesktopSplitScreen();
        }
        return const UnpackingOperationListScreen();
      },
    );
  }
}
