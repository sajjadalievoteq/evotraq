import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/operations_header/widgets/home_operations_header_actions.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/operations_header/widgets/home_operations_search_field.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

class OperationsHeader extends StatelessWidget {
  const OperationsHeader({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    final titleStyle = layout.isCompact
        ? context.text.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          )
        : context.text.h2.copyWith(
            fontSize: 24,
            height: 1.2,
            letterSpacing: -0.33,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          );

    final title = Text(HomeStrings.operationsHeaderTitle, style: titleStyle);

    final actions = HomeOperationsHeaderActions();

    if (layout.isTabletUp) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          const SizedBox(width: 12),
          Expanded(
            child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
              children: [
               SizedBox(
                   width: 400,
                   child: HomeOperationsSearchField()),
                const SizedBox(width: 5),
                actions,
              ],
            ),
          ),

        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            title,
            Align(
              alignment: Alignment.centerRight,
              child: actions,
            ),
          ],
        ),
        const SizedBox(height: 12),
        HomeOperationsSearchField(),
        const SizedBox(height: 12),

      ],
    );
  }
}
