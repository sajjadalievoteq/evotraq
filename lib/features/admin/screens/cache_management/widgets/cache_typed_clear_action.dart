import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheTypedClearAction extends StatelessWidget {
  const CacheTypedClearAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onClear,
  });
  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TraqIcon(iconAsset),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: ElevatedButton(onPressed: onClear, child: const Text('Clear')),
    );
  }
}
