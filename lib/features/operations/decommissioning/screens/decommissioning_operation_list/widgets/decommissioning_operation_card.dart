import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_status.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_status_utils.dart';

class DecommissioningOperationCard extends StatelessWidget {
  const DecommissioningOperationCard({
    super.key,
    required this.operation,
    required this.isSelected,
    required this.onTap,
  });

  final DecommissioningResponse operation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = operation;
    final status = op.status ?? DecommissioningStatus.failed;
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
                      color: DecommissioningStatusUtils.colorFor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      DecommissioningStatusUtils.label(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${op.itemCount ?? 0} EPCs',
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
                op.decommissioningReference ?? 'Decommissioning Operation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (op.locationGLN != null)
                Row(
                  children: [
                    TraqIcon(AppAssets.iconMapPin, color: isSelected ? Colors.white70 : Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        op.locationGLN!,
                        style: TextStyle(color: selectedTextColor),
                      ),
                    ),
                  ],
                ),
              if (op.disposition != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Disposition: ${op.disposition}',
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
              if (op.processedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  DateFormat.yMMMd().add_jm().format(op.processedAt!.toLocal()),
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
