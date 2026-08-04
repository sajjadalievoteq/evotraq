import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class JobQueueLoadingView extends StatelessWidget {
  const JobQueueLoadingView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final skeletons = List.generate(
      4,
      (_) => TraqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: TraqSpacing.xl,
              width: 160,
              decoration: BoxDecoration(
                color: c.surfaceMuted,
                borderRadius: TraqRadius.chip,
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.surfaceMuted,
                borderRadius: TraqRadius.card,
              ),
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      return Column(
        children: [
          for (var i = 0; i < skeletons.length; i++) ...[
            if (i > 0) const SizedBox(height: TraqSpacing.md),
            skeletons[i],
          ],
        ],
      );
    }

    return ListView.separated(
      padding: TraqSpacing.surfacePad,
      itemCount: skeletons.length,
      separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.md),
      itemBuilder: (_, i) => skeletons[i],
    );
  }
}
