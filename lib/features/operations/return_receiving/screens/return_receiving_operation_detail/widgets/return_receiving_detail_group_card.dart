import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Gs1GroupCard wrapper used across Return Receiving Detail sections.
class ReturnReceivingDetailGroupCard extends StatelessWidget {
  const ReturnReceivingDetailGroupCard({
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

