import 'package:flutter/material.dart';

class EmptyStateActionRow extends StatelessWidget {
  const EmptyStateActionRow({super.key, required this.actions, required this.fullWidth});

  final List<Widget> actions;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    if (fullWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            actions[i],
          ],
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: actions,
    );
  }
}
