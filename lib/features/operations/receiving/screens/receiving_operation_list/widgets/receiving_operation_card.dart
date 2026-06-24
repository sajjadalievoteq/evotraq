import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_status.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_status_utils.dart';

/// List card for a single Receiving operation.
class ReceivingOperationCard extends StatelessWidget {
  const ReceivingOperationCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final ReceivingResponse operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
    final status = op.status ?? ReceivingStatus.failed;
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
                      color: ReceivingStatusUtils.colorFor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ReceivingStatusUtils.label(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${op.processedEpcsCount ?? op.epcList?.length ?? 0} EPCs',
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
                op.receivingReference ?? 'Receiving Operation',
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
                    const Icon(Icons.flight_takeoff, size: 16, color: Colors.green),
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
              if (op.receivingGLN != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.flight_land, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'To: ${op.receivingGLN}',
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
                      const Icon(Icons.local_shipping, size: 16, color: Colors.orange),
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
                      const Icon(Icons.qr_code_2, size: 16, color: Colors.blue),
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
