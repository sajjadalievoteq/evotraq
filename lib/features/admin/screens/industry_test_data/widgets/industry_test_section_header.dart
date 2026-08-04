import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class IndustryTestSectionHeader extends StatelessWidget {
  const IndustryTestSectionHeader(
    this.title,
    this.iconAsset, {
    super.key,
  });

  final String title;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TraqIcon(iconAsset, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
