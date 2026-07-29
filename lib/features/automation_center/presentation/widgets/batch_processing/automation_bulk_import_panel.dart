import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_batch_import/object_event_batch_import_screen.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class AutomationBulkImportPanel extends StatelessWidget {
  const AutomationBulkImportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkbenchPanelShell(
      title: 'Bulk Import',
      slice: const WorkbenchSlice(),
      expandBody: true,
      child: BlocProvider<ObjectEventsCubit>(
        create: (_) => ObjectEventsCubit(),
        child: const ObjectEventBatchImportScreen(embedded: true),
      ),
    );
  }
}
