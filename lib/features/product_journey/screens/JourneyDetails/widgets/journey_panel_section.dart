import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_section_title.dart';

class JourneyPanelSection extends StatelessWidget {
  const JourneyPanelSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
          child: Row(
            children: [
              Expanded(child: TraqSectionTitle(label: title.toUpperCase())),
              ?trailing,
            ],
          ),
        ),
        child,
      ],
    );
  }
}
