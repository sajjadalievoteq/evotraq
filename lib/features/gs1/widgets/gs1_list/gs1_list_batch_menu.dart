import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_toolbar_constants.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

class Gs1ListBatchMenu extends StatelessWidget {
  const Gs1ListBatchMenu({
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageSizeChanged,
  });

  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final selectedSize = pageSize ?? pageSizeOptions.first;
    return PopupMenuButton<int>(
      tooltip: 'Batch size ($selectedSize)',
      padding: EdgeInsets.zero,
      icon: TraqIcon(AppAssets.iconLayers, size: kGs1ListFieldIconSize),
      iconColor: kGs1ListToolbarIconColor,
      iconSize: kGs1ListFieldIconSize,
      initialValue: selectedSize,
      onSelected: onPageSizeChanged,
      itemBuilder: (context) => pageSizeOptions
          .map(
            (size) =>
                PopupMenuItem<int>(value: size, child: Text('$size/batch')),
          )
          .toList(),
    );
  }
}
