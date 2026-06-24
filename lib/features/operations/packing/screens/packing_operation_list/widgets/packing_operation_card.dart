import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_status.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_status_utils.dart';

/// List card for a single packing operation.
class PackingOperationCard extends StatelessWidget {
  const PackingOperationCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final PackingResponse operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
    final status = op.status ?? PackingStatus.failed;
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
                      color: PackingStatusUtils.colorFor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      PackingStatusUtils.label(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      '${op.packedItemsCount ?? 0} items',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                op.packingReference ?? 'Packing Operation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (op.parentContainerId != null)
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Colors.brown,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Container: ${op.parentContainerId}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              if (op.parentContainerId != null) const SizedBox(height: 4),
              if (op.packingLocationGLN != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location: ${op.packingLocationGLN}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              if (op.workOrderNumber != null || op.batchNumber != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (op.workOrderNumber != null) ...[
                      const Icon(Icons.work, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'WO: ${op.workOrderNumber}',
                        style: TextStyle(color: selectedTextColor),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (op.batchNumber != null) ...[
                      const Icon(
                        Icons.batch_prediction,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Batch: ${op.batchNumber}',
                        style: TextStyle(color: selectedTextColor),
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
                    '${op.packedItemsCount ?? 0} items packed',
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
