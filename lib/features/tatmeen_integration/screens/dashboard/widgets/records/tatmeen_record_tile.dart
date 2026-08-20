part of 'tatmeen_records_table.dart';

class TatmeenRecordTile extends StatelessWidget {
  const TatmeenRecordTile({
    super.key,
    required this.record,
    required this.busy,
    required this.onRetry,
  });

  final TatmeenSyncRecord record;
  final bool busy;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return TraqCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => showTatmeenOperationDetailsDialog(
                    context,
                    record: record,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DisplayDateUtils.dmyHm(record.createdAt),
                        style: context.text.bodySm.copyWith(color: muted),
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(record.operationType, style: context.text.body),
                      Text(record.operationId, style: context.text.bodySm),
                      Text(
                        '${record.attemptsLabel}  ·  ${record.durationLabel}',
                        style: context.text.bodySm.copyWith(color: muted),
                      ),
                      Tooltip(
                        message: record.message,
                        child: Text(
                          record.truncatedMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySm.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TraqSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TatmeenSyncStatusBadge(status: record.status),
                  if (record.status == TatmeenSyncStatus.failed)
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final confirmed =
                                  await showTatmeenRetryRecordDialog(context);
                              if (confirmed) await onRetry();
                            },
                      child: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Retry'),
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
