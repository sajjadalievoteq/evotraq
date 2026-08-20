part of 'tatmeen_recent_activity.dart';

class TatmeenActivityListTile extends StatelessWidget {
  const TatmeenActivityListTile({super.key, required this.event});

  final TatmeenSyncEvent event;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DisplayDateUtils.dmyHm(event.timestamp),
                  style: context.text.bodySm.copyWith(color: muted),
                ),
              ),
              TatmeenActivityStatusBadge(status: event.status),
            ],
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(event.recordType, style: context.text.body),
          const SizedBox(height: TraqSpacing.xs),
          Tooltip(
            message: event.recordId,
            child: Text(
              event.recordId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySm,
            ),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Tooltip(
            message: event.message,
            child: Text(
              event.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySm.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
