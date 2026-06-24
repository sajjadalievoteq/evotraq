import 'package:flutter/material.dart';

/// Context banner showing the selected parent container for item scanning.
class UnpackingContainerSummaryBanner extends StatelessWidget {
  const UnpackingContainerSummaryBanner({
    super.key,
    required this.parentContainerId,
    required this.unpackingReference,
  });

  final String? parentContainerId;
  final String unpackingReference;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.inventory_2, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Container: ${parentContainerId ?? 'Not selected'}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Reference: ${unpackingReference.isNotEmpty ? unpackingReference : '—'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
