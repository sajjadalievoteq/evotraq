import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_step_card.dart';

class JourneyTimelinePanel extends StatefulWidget {
  const JourneyTimelinePanel({
    super.key,
    required this.journey,
    required this.selectedStep,
    required this.onStepSelected,
    this.scrollController,
  });

  final ProductJourney journey;
  final JourneyStep? selectedStep;
  final ValueChanged<JourneyStep> onStepSelected;
  final ScrollController? scrollController;

  @override
  State<JourneyTimelinePanel> createState() => JourneyTimelinePanelState();
}

class JourneyTimelinePanelState extends State<JourneyTimelinePanel> {
  ScrollController? _ownedScroll;

  ScrollController get _scroll =>
      widget.scrollController ?? (_ownedScroll ??= ScrollController());

  void scrollToStep(int index) {
    const itemHeight = 120.0;
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      index * itemHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _ownedScroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.journey.steps;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return JourneyStepCard(
          step: step,
          index: index,
          total: steps.length,
          isSelected: widget.selectedStep?.eventId == step.eventId,
          previousStep: index > 0 ? steps[index - 1] : null,
          onTap: () => widget.onStepSelected(step),
        );
      },
    );
  }
}
