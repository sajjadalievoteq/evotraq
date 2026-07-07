import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';

/// Shared EPCIS events card for operation detail screens.
class OperationDetailEventsCard extends StatelessWidget {
  const OperationDetailEventsCard({super.key, required this.eventIds});

  final List<String> eventIds;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'EPCIS Events (${eventIds.length})',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: eventIds
              .map(
                (id) => ActionChip(
                  avatar: TraqIcon(AppAssets.iconAggregate, size: 14),
                  label: Text(
                    id.length > 16 ? '…${id.substring(id.length - 16)}' : id,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () =>
                      context.go('${Constants.epcisObjectEventsRoute}/$id'),
                  tooltip: id,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
