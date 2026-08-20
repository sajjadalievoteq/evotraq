part of 'tatmeen_recent_activity.dart';

class TatmeenActivityStatusBadge extends StatelessWidget {
  const TatmeenActivityStatusBadge({super.key, required this.status});
  final TatmeenSyncStatus status;
  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      TatmeenSyncStatus.successful => ('Successful', context.colors.success),
      TatmeenSyncStatus.failed => ('Failed', context.colors.error),
      TatmeenSyncStatus.pending => ('Pending', context.colors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: TraqRadius.chip,
      ),
      child: Text(
        text,
        style: context.text.bodySm.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
