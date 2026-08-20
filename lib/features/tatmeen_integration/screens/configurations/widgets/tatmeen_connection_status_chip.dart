part of 'tatmeen_detail_pane.dart';

class TatmeenConnectionStatusChip extends StatelessWidget {
  const TatmeenConnectionStatusChip({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = enabled
        ? colors.success.withValues(alpha: 0.12)
        : colors.textMuted.withValues(alpha: 0.12);
    final fg = enabled ? colors.success : colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(
            enabled ? AppAssets.iconCheckCircle : AppAssets.iconPause,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: TraqSpacing.xs),
          Text(
            enabled ? 'Integration enabled' : 'Integration disabled',
            style: context.text.bodySm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
