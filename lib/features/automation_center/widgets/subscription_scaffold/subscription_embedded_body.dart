import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class SubscriptionEmbeddedBody extends StatelessWidget {
  const SubscriptionEmbeddedBody({
    super.key,
    required this.description,
    required this.filterChips,
    required this.body,
    this.expandBody = true,
  });

  final Widget description;
  final Widget filterChips;
  final Widget body;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        description,
        const SizedBox(height: TraqSpacing.lg),
        filterChips,
        const SizedBox(height: TraqSpacing.lg),
        Divider(height: 1, color: c.border),
        const SizedBox(height: TraqSpacing.lg),
        if (expandBody) Expanded(child: body) else body,
      ],
    );
  }
}