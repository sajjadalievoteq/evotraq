import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_serial_status_badge.dart';

class CommissioningSerialList extends StatelessWidget {
  const CommissioningSerialList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  final List<CommissioningEpcItem> items;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final label = item.parsed.serial ?? item.parsed.sscc ?? item.epc;
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(
              label,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            subtitle: item.blockReason != null
                ? Text(
                    item.blockReason!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                : Text(
                    '${item.parsed.typeLabel} · ${item.sourceStatus ?? '…'} → ${item.targetStatus ?? 'COMMISSIONED'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommissioningSerialStatusBadge(status: item.poolStatus),
                const SizedBox(width: 4),
                IconButton(
                  icon: TraqIcon(AppAssets.iconX, size: 20),
                  onPressed: () => onRemove(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
