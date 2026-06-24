import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_batch_status_utils.dart';

class CommissioningOperationListCard extends StatelessWidget {
  const CommissioningOperationListCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final CommissioningBatch operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
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
                      color: CommissioningBatchStatusUtils.color(op.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      CommissioningBatchStatusUtils.label(op.status),
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
                      '${op.totalCommissioned} items',
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
                op.commissioningReference ??
                    (op.gtinCode != null
                        ? 'GTIN: ${op.gtinCode}'
                        : 'Commissioning Operation'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (op.gtinCode != null)
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'GTIN: ${op.gtinCode}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              if (op.gtinCode != null) const SizedBox(height: 4),
              if (op.batchLotNumber != null)
                Row(
                  children: [
                    const Icon(Icons.numbers, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      'Lot #: ${op.batchLotNumber}',
                      style: TextStyle(color: selectedTextColor),
                    ),
                  ],
                ),
              if (op.batchLotNumber != null) const SizedBox(height: 4),
              if (op.commissioningLocationGLN != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location: ${op.commissioningLocationGLN}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${op.totalCommissioned} commissioned',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (op.totalFailed > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.error, size: 14, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${op.totalFailed} failed',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (op.createdAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(op.createdAt!),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
