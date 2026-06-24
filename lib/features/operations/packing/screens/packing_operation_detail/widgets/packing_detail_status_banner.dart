import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';

/// Status banner with background image for packing operation detail.
class PackingDetailStatusBanner extends StatelessWidget {
  const PackingDetailStatusBanner({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: context.colors.surface,
      clipBehavior: Clip.hardEdge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.primary,
          image: DecorationImage(
            image: AssetImage(AppAssets.traqBackgroundPng),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operation.packingReference ?? 'Packing Operation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (operation.packingOperationId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${operation.packingOperationId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (operation.packedItemsCount != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${operation.packedItemsCount} Items',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
