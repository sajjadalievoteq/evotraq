import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheManagementAction extends StatelessWidget {
  const CacheManagementAction({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.onExecute,
    this.isDestructive = false,
  });
  final String title;
  final String description;
  final String iconAsset;
  final VoidCallback onExecute;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final errorColor = AppColorMapper.errorColor(context);
    return ListTile(
      leading: TraqIcon(iconAsset, color: isDestructive ? errorColor : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? errorColor : null),
      ),
      subtitle: Text(description),
      trailing: ElevatedButton(
        onPressed: onExecute,
        style: isDestructive
            ? ElevatedButton.styleFrom(backgroundColor: errorColor)
            : null,
        child: Text(isDestructive ? 'Clear' : 'Execute'),
      ),
    );
  }
}
