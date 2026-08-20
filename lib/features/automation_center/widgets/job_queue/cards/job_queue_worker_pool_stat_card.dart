import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';

class JobQueueWorkerPoolStatCard extends StatelessWidget {
  final String title;
  final String value;

  const JobQueueWorkerPoolStatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TraqCard(
      padding: TraqSpacing.surfacePad,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: context.text.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            title,
            style: context.text.cap.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
