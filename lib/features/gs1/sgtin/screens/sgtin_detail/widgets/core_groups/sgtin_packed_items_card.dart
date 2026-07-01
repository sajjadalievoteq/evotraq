import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Lists child EPCs packed inside an SGTIN when it acts as a container.
class SgtinPackedItemsCard extends StatelessWidget {
  const SgtinPackedItemsCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    if (sgtin.childEpcs.isEmpty) return const SizedBox.shrink();

    return Gs1GroupCard(
      title: 'Packed Items (${sgtin.childEpcs.length})',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...sgtin.childEpcs.take(20).map(
                (epc) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    epc,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
          if (sgtin.childEpcs.length > 20)
            Text(
              '+ ${sgtin.childEpcs.length - 20} more',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }
}
