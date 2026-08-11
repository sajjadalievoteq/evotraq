import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_painter.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_header_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_diagram_skeleton.dart';

export 'journey_canvas_header_skeleton.dart';
export 'journey_canvas_diagram_skeleton.dart';
export 'journey_pin_skeleton.dart';

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
