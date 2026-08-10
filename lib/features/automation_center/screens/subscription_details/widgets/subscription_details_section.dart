import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class SubscriptionDetailsSection extends StatelessWidget {
  const SubscriptionDetailsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: context.text.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: TraqSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: TraqRadius.card,
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, color: c.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
