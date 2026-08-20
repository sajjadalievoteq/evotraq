import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_item_shimmer.dart';


class Gs1ListLoadingShimmer extends StatelessWidget {
  const Gs1ListLoadingShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Constants.sectionMaxWidth,
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: context.padding.left),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return Gs1ListItemShimmer(
                    baseColor: baseColor,
                    isCompact: isCompact,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
