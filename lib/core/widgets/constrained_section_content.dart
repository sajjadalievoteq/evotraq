import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class ConstrainedSectionContent extends StatelessWidget {
  const ConstrainedSectionContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.sectionMaxWidth),
        child: child,
      ),
    );
  }
}
