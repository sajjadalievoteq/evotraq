import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';

class SgtinDetailScaffold extends StatelessWidget {
  const SgtinDetailScaffold({
    super.key,
    required this.appBarTitle,
    required this.showEditAction,
    required this.showCloseEditAction,
    required this.onEdit,
    required this.onCloseEdit,
    required this.body,
    required this.showSaveFab,
    required this.isSaving,
    required this.onSave,
  });

  final String appBarTitle;
  final bool showEditAction;
  final bool showCloseEditAction;
  final VoidCallback onEdit;
  final VoidCallback onCloseEdit;
  final Widget body;
  final bool showSaveFab;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: Text(appBarTitle),
        actions: [
          if (showEditAction)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          if (showCloseEditAction)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onCloseEdit,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: showSaveFab
          ? FloatingActionButton(
              onPressed: onSave,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
            )
          : null,
    );
  }
}
