import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/product_hierarchy/cubit/product_hierarchy_cubit.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';


class ProductHierarchySidebarActions extends StatelessWidget {
  const ProductHierarchySidebarActions({super.key, required this.identifier});
  final String identifier;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductHierarchyCubit>();
    final c = context.colors;
    final canAct = identifier.trim().isNotEmpty && cubit.state.root != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Actions'),
        Wrap(
          spacing: TraqSpacing.sm,
          runSpacing: TraqSpacing.sm,
          children: [
            CustomButtonWidget(
              title: 'Copy Identifier',
              iconAsset: AppAssets.iconCopy,
              onTap: !canAct
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: identifier),
                      );
                      if (context.mounted) {
                        context.showSuccess(
                          'Identifier copied',
                          duration: const Duration(seconds: 1),
                        );
                      }
                    },
            ),
            CustomButtonWidget(
              title: 'Expand All',
              iconAsset: AppAssets.iconChevronD,
              backgroundColor: c.surfaceMuted,
              foregroundColor: c.textPrimary,
              onTap: !canAct ? null : () => cubit.expandAll(),
            ),
            CustomButtonWidget(
              title: 'Collapse All',
              iconAsset: AppAssets.iconChevronR,
              backgroundColor: c.surfaceMuted,
              foregroundColor: c.textPrimary,
              onTap: !canAct ? null : cubit.collapseAll,
            ),
          ],
        ),
      ],
    );
  }
}
