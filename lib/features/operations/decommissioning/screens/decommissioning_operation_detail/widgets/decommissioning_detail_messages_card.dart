import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Messages card for Decommissioning operation detail.
class DecommissioningDetailMessagesCard extends StatelessWidget {
  const DecommissioningDetailMessagesCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    final msgs = operation.messages ?? [];

    return DecommissioningDetailGroupCard(
      title: 'Messages',
      children: msgs
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TraqIcon(AppAssets.iconInfo,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(m, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
