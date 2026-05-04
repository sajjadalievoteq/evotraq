import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

/// Shared shell for GTIN/GLN (and similar) master-data detail: optional [Scaffold] or body-only when [embedded].
class Gs1MasterDataDetailScaffold extends StatelessWidget {
  const Gs1MasterDataDetailScaffold({
    super.key,
    required this.embedded,
    required this.body,
    this.title,
    this.showSaveAction = false,
    this.onSave,
    this.saveEnabled = true,
    this.saveActionTooltip = 'Save',
  });

  final bool embedded;
  final Widget body;
  final String? title;
  final bool showSaveAction;
  final VoidCallback? onSave;
  final bool saveEnabled;
  final String saveActionTooltip;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: title == null
            ? null
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          if (showSaveAction && onSave != null)
            IconButton(
              tooltip: saveActionTooltip,
              icon: const Icon(Icons.save),
              onPressed: saveEnabled ? onSave : null,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
