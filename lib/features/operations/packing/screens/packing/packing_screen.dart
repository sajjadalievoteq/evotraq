import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_desktop_split/packing_desktop_split_screen.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_list/packing_operation_list_screen.dart';

class PackingScreen extends StatelessWidget {
  const PackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return const PackingDesktopSplitScreen();
        }
        return const PackingOperationListScreen();
      },
    );
  }
}
