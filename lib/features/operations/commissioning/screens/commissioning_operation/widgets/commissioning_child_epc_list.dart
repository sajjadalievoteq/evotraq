import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_child_epc_item.dart';

class CommissioningChildEpcList extends StatelessWidget {
  const CommissioningChildEpcList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  final List<CommissioningChildEpcItem> items;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'No child SGTINs linked — optional.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = Theme.of(context);
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Text(
              item.displayKey,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            subtitle: item.statusWarning != null
                ? Text(
                    item.statusWarning!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade800,
                    ),
                  )
                : Text(
                    'SGTIN · ready for aggregation',
                    style: theme.textTheme.bodySmall,
                  ),
            trailing: IconButton(
              icon: TraqIcon(AppAssets.iconX, size: 18),
              onPressed: () => onRemove(index),
            ),
          ),
        );
      },
    );
  }
}
