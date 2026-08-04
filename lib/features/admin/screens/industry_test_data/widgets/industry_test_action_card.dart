import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class IndustryTestActionCard extends StatelessWidget {
  const IndustryTestActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.color,
    required this.onPressed,
    required this.buttonText,
    this.isDisabled = false,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Color color;
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TraqIcon(iconAsset, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: isDisabled ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: TraqIcon(
                  isDisabled ? AppAssets.iconLock : AppAssets.iconPlay,
                ),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.grey.shade300 : color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
