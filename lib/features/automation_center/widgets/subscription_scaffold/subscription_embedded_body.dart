import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Shared embedded panel body: description row, filters, divider, list slot.
class SubscriptionEmbeddedBody extends StatelessWidget {
  const SubscriptionEmbeddedBody({
    super.key,
    required this.description,
    required this.filterChips,
    required this.body,
  });

  /// Leading description text (and optional trailing widget such as live status).
  final Widget description;
  final Widget filterChips;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        description,
        const SizedBox(height: TraqSpacing.lg),
        filterChips,
        const SizedBox(height: TraqSpacing.lg),
        Divider(height: 1, color: c.border),
        const SizedBox(height: TraqSpacing.lg),
        Expanded(child: body),

      ],
    );
  }
}
