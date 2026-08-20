import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_header_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_diagram_skeleton.dart';


class JourneyCanvasSkeleton extends StatelessWidget {
  const JourneyCanvasSkeleton({super.key, this.includeHeader = true});

  final bool includeHeader;

  @override
  Widget build(BuildContext context) {
    if (!includeHeader) {
      return const JourneyCanvasDiagramSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: journeyCanvasHeaderPadding(context),
          child: const JourneyCanvasHeaderSkeleton(),
        ),
        const Expanded(child: JourneyCanvasDiagramSkeleton()),
      ],
    );
  }
}

EdgeInsets journeyCanvasHeaderPadding(BuildContext context) {
  return EdgeInsets.fromLTRB(
    context.padding.top,
    context.padding.top,
    context.padding.top,
    TraqSpacing.sm,
  );
}
