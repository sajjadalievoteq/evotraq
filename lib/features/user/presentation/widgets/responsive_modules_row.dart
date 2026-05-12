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

        final columns =
            constraints.maxWidth >= UserUiConstants.threeColumnBreakpoint
            ? 3
            : 2;

        final rowCount = (children.length / columns).ceil();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(rowCount, (rowIndex) {
            final start = rowIndex * columns;
            final end = (start + columns).clamp(0, children.length);

            final rowChildren = children.sublist(start, end);

            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex == rowCount - 1 ? 0 : spacing,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(columns, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == columns - 1 ? 0 : spacing,
                        ),
                        child: index < rowChildren.length
                            ? rowChildren[index]
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
