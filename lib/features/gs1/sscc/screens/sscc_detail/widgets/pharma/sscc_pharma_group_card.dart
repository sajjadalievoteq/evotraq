import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccPharmaGroupCard extends StatelessWidget {
  const SsccPharmaGroupCard({
    super.key,
    required this.outlineColor,
    required this.title,
    required this.child,
  });

  final Color outlineColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: title,
      outlineColor: outlineColor,
      child: child,
    );
  }
}
