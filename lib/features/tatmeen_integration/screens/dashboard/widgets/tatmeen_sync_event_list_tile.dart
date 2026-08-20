import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_status_badge.dart';

class TatmeenSyncEventListTile extends StatelessWidget {
  const TatmeenSyncEventListTile({
    super.key,
    required this.event,
    required this.attempts,
    required this.onRetry,
  });

  final TatmeenSyncEvent event;
  final int? attempts;
  final ValueChanged<TatmeenSyncEvent>? onRetry;

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
              TatmeenSyncStatusBadge(status: event.status),
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
          if (attempts != null) ...[
            const SizedBox(height: TraqSpacing.xs),
            Text(
              'Attempts: $attempts',
              style: context.text.bodySm.copyWith(color: muted),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: TraqSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onRetry!(event),
                child: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
