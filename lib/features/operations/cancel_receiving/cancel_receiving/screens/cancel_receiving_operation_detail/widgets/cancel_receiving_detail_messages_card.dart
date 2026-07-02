import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Messages card for shipping operation detail.
class CancelReceivingDetailMessagesCard extends StatelessWidget {
  const CancelReceivingDetailMessagesCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    final msgs = operation.messages ?? [];

    return CancelReceivingDetailGroupCard(
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
