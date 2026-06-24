import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

class CommissioningDetailSerialItemRow extends StatelessWidget {
  const CommissioningDetailSerialItemRow({
    super.key,
    required this.item,
  });

  final CommissioningBatchItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            item.success ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: item.success ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serialNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.epcUri != null)
                  Text(
                    item.epcUri!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!item.success && item.errorMessage != null)
                  Text(
                    item.errorMessage!,
                    style: TextStyle(fontSize: 11, color: Colors.red[600]),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.serialNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied: ${item.serialNumber}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
