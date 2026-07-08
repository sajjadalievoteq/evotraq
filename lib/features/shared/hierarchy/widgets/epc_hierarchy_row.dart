import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_navigation.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class EpcHierarchyRow extends StatelessWidget {
  const EpcHierarchyRow({
    super.key,
    required this.epc,
    required this.hierarchyScreenTitle,
    this.trailing,
    this.subtitle,
    this.showCopy = true,
  });

  final String epc;
  final String hierarchyScreenTitle;
  final Widget? trailing;
  final Widget? subtitle;
  final bool showCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  epc,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                ?subtitle,
              ],
            ),
          ),
          if (showCopy)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: epc));
                context.showSuccess('Copied', duration: const Duration(seconds: 1));
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: TraqIcon(AppAssets.iconCopy, size: 16),
              ),
            ),
          IconButton(
            icon: TraqIcon(AppAssets.iconAggregate, size: 18),
            tooltip: 'View hierarchy',
            visualDensity: VisualDensity.compact,
            onPressed: () => openHierarchyScreen(
              context,
              epc: epc,
              title: hierarchyScreenTitle,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
