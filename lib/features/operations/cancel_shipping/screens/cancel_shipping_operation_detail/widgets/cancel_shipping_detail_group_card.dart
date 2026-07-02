import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Gs1GroupCard wrapper used across shipping detail sections.
class CancelShippingDetailGroupCard extends StatelessWidget {
  const CancelShippingDetailGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: title,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
