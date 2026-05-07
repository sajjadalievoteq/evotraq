import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/user/utils/user_ui_constants.dart';

class ResponsiveModulesRow extends StatelessWidget {
  const ResponsiveModulesRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final availableWidth = constraints.maxWidth;
        final columns =
            availableWidth >= UserUiConstants.threeColumnBreakpoint ? 3 : 2;
        final rowCount = (children.length / columns).ceil();

        Widget buildRow(int rowIndex) {
          final start = rowIndex * columns;
          final endExclusive = (start + columns).clamp(0, children.length);
          final rowChildren = children.sublist(start, endExclusive);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i < rowChildren.length)
                    Expanded(child: rowChildren[i])
                  else
                    const Expanded(child: SizedBox.shrink()),
                  if (i != columns - 1) const SizedBox(width: spacing),
                ],
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < rowCount; row++) ...[
              buildRow(row),
              if (row != rowCount - 1) const SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }
}

