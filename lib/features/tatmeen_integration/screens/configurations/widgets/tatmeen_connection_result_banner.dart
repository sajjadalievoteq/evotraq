part of 'tatmeen_detail_pane.dart';

class TatmeenConnectionResultBanner extends StatelessWidget {
  const TatmeenConnectionResultBanner({super.key, required this.result});

  final TatmeenConnectionTestResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = result.success;
    final bg = success
        ? colors.success.withValues(alpha: 0.12)
        : colors.error.withValues(alpha: 0.12);
    final fg = success ? colors.success : colors.error;
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        result.message,
        style: context.text.bodySm.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
