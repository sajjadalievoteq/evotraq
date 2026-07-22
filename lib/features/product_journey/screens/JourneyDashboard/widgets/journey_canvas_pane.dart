import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/cubit/journey_cubit.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_empty_state.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_skeleton.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_event_filter_chips.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_pin_canvas.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_timeline_header.dart';

class JourneyCanvasPane extends StatelessWidget {
  const JourneyCanvasPane({
    super.key,
    required this.state,
    required this.onStepTapped,
  });

  final JourneyState state;
  final ValueChanged<JourneyStep> onStepTapped;

  @override
  Widget build(BuildContext context) {
    if (state.isLoaded && state.journey != null) {
      return AnimatedSwitcher(
        duration: JourneyAnimationConstants.canvasPaneSwitch,
        switchInCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: Column(
          key: ValueKey(state.journey!.identifier),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: journeyCanvasHeaderPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  JourneyTimelineHeader(journey: state.journey!),
                  const SizedBox(height: TraqSpacing.sm),
                  JourneyEventFilterChips(
                    selected: state.eventFilter,
                    onSelected: (filter) =>
                        context.read<JourneyCubit>().setEventFilter(filter),
                  ),
                ],
              ),
            ),
            Expanded(
              child: JourneyPinsCanvas(
                journey: state.journey!,
                selectedStep: state.selectedStep,
                onStepTapped: onStepTapped,
                eventFilter: state.eventFilter,
              ),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      
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

    if (!state.hasError && state.journey == null) {
      return const Center(child: JourneyEmptyState());
    }

    return const SizedBox.shrink();
  }
}
