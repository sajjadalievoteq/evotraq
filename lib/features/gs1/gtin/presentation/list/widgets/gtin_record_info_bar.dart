import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../../../../../shared/layout/layout_manager.dart';

class GtinRecordInfoBar extends StatelessWidget {
  const GtinRecordInfoBar({
    super.key,
    required this.loadedRecords,
    required this.hasMoreData,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int loadedRecords;
  final bool hasMoreData;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showText = hasMoreData
        ? 'Showing $loadedRecords+ GTINs (scroll for more)'
        : 'Showing all $loadedRecords GTINs';

    Widget buildPageSizeDropdown({bool compact = false}) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: pageSize,
          isDense: true,
          items: GtinUiConstants.pageSizeOptions.map((size) {
            return DropdownMenuItem(
              value: size,
              child: Text(
                '$size/batch',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (newSize) {
            if (newSize != null) onPageSizeChanged(newSize);
          },
        ),
      );
    }

    Widget buildLoadedBatches() {
      if (!hasMoreData) return const SizedBox.shrink();
      return Text(
        'Loaded: ${(loadedRecords / pageSize).ceil()} batches',
        style: theme.textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AppLayoutBuilder(
      builder: (context, layout) {
        final horizontalMargin = layout.width < 420 ? 8.0 : 16.0;
        final padding = EdgeInsets.symmetric(
          horizontal: layout.resolve(compact: 12.0, medium: 16.0),
          vertical: layout.resolve(compact: 10.0, medium: 8.0),
        );

        final container = Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4.0),
          padding: padding,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.cardRadius),
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: layout.isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,

                        children: [
                           if (hasMoreData) buildLoadedBatches(),

                          buildPageSizeDropdown(compact: true),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        showText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasMoreData) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: buildLoadedBatches(),
                          ),
                          const SizedBox(width: 16),
                        ],

                        buildPageSizeDropdown(),
                      ],
                    ),
                  ],
                ),
        );

        return container;
      },
    );
  }
}

