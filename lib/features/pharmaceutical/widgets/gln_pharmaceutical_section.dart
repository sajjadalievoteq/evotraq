import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class GlnPharmaceuticalSection extends StatelessWidget {
  const GlnPharmaceuticalSection({
    required this.title,
    required this.iconAsset,
    required this.children,
    super.key,
  });

  const GlnPharmaceuticalSection.fromParts(
    this.title,
    this.iconAsset,
    this.children,
    BuildContext _, {
    super.key,
  });

  final String title;
  final String iconAsset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  iconAsset,
                  size: 20,
                  color: context.colors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
