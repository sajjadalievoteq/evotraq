import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyViolationItem extends StatelessWidget {
  const ConsistencyViolationItem(
    this.title,
    this.description,
    this.iconAsset,
    this.color, {
    super.key,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: TraqIcon(iconAsset, color: color),
        title: Text(title),
        subtitle: Text(description),
        trailing: TraqIcon(
          AppAssets.iconChevronR,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
