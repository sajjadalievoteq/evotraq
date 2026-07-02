import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_status.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_status_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// List card for a single shipping operation.
class CancelShippingOperationCard extends StatelessWidget {
  const CancelShippingOperationCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final CancelShippingResponse operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
    final status = op.status ?? CancelShippingStatus.failed;
    final selectedTextColor = isSelected ? Colors.white : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CancelShippingStatusUtils.colorFor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      CancelShippingStatusUtils.label(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${op.cancelledEpcsCount ?? op.epcList?.length ?? 0} EPCs',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                op.cancelShippingReference ?? 'Cancel Shipping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (op.sourceGLN != null)
                Row(
                  children: [
                    const TraqIcon(AppAssets.iconAirplaneUp, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'From: ${op.sourceGLN}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              if (op.destinationGLN != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const TraqIcon(AppAssets.iconAirplaneD, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'To: ${op.destinationGLN}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              ],
              if (op.cancelReason != null && op.cancelReason!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TraqIcon(AppAssets.iconDocument, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        op.cancelReason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${op.eventIds?.length ?? 0} events',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (op.processedAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(op.processedAt!),
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}