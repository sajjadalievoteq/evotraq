part of 'tatmeen_sync_chart.dart';

class TatmeenChartLegendDot extends StatelessWidget {
  const TatmeenChartLegendDot({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: TraqSpacing.xs),
        Text(label, style: context.text.bodySm),
      ],
    );
  }
}
