import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_status.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_status_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// List card for a single shipping operation.
class ReturnShippingOperationCard extends StatelessWidget {
  const ReturnShippingOperationCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final ReturnShippingResponse operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
    final status = op.status ?? ReturnShippingStatus.failed;
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
                      color: ReturnShippingStatusUtils.colorFor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ReturnShippingStatusUtils.label(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${op.shippedEpcsCount ?? op.epcList?.length ?? 0} EPCs',
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
                op.returnReference ?? 'Return Shipping',
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
              if ((op.carrier != null && op.carrier!.isNotEmpty) ||
                  (op.trackingNumber != null && op.trackingNumber!.isNotEmpty)) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (op.carrier != null && op.carrier!.isNotEmpty) ...[
                      TraqIcon(AppAssets.iconShipment, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          op.carrier!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: selectedTextColor),
                        ),
                      ),
                    ],
                    if (op.trackingNumber != null && op.trackingNumber!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TraqIcon(AppAssets.iconQr, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          op.trackingNumber!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: selectedTextColor),
                        ),
                      ),
                    ],
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