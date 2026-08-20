import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenStatusBreakdownLegend extends StatelessWidget {
  const TatmeenStatusBreakdownLegend({super.key, required this.breakdown});

  final TatmeenStatusBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          [
            ('Successful', breakdown.successful, context.colors.success),
            ('Failed', breakdown.failed, context.colors.error),
            ('Pending', breakdown.pending, context.colors.warning),
          ].map((section) {
            final percentage = section.$2 / breakdown.total * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: section.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: TraqSpacing.xs),
                  Expanded(child: Text(section.$1, style: context.text.bodySm)),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: context.text.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
