import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';

class Gs1MasterDataDetailScaffold extends StatelessWidget {
  const Gs1MasterDataDetailScaffold({
    super.key,
    required this.embedded,
    required this.body,
    this.title,
    this.showSaveAction = false,
    this.onSave,
    this.saveEnabled = true,
    this.saveInProgress = false,
    this.saveActionTooltip = 'Save',
  });

  final bool embedded;
  final Widget body;
  final String? title;
  final bool showSaveAction;
  final VoidCallback? onSave;
  final bool saveEnabled;
  final bool saveInProgress;
  final String saveActionTooltip;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: title == null
            ? null
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          if (showSaveAction && onSave != null)
            saveInProgress
                ? IconButton(
                    onPressed: null,
                    tooltip: saveActionTooltip,
                    icon: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: saveActionTooltip,
                    icon: const TraqIcon(AppAssets.iconSave),
                    onPressed: saveEnabled ? onSave : null,
                  ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
