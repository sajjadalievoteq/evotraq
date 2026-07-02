import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Status banner with background image for shipping operation detail.
class CancelReceivingDetailStatusBanner extends StatelessWidget {
  const CancelReceivingDetailStatusBanner({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

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
                    operation.cancelReceivingReference ?? 'Cancel Receiving Operation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (operation.cancelReceivingOperationId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${operation.cancelReceivingOperationId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (operation.shippedItemsCount != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TraqIcon(AppAssets.iconPackage,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${operation.shippedItemsCount} Items',
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
