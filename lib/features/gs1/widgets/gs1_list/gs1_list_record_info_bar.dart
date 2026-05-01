import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// “Showing N+ … / page size” row (GTIN/GLN list “information” tile).
class Gs1ListRecordInfoBar extends StatelessWidget {
  const Gs1ListRecordInfoBar({
    super.key,
    required this.entityPlural,
    required this.loadedRecords,
    required this.hasMoreData,
    required this.pageSize,
    required this.onPageSizeChanged,
    this.pageSizeOptions = Gs1ListPageSizes.defaults,
  });

  /// e.g. `"GTINs"` or `"GLNs"`.
  final String entityPlural;
  final int loadedRecords;
  final bool hasMoreData;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizeOptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showText = hasMoreData
        ? 'Showing $loadedRecords+ $entityPlural (scroll for more)'
        : 'Showing all $loadedRecords $entityPlural';

    Widget buildPageSizeDropdown() {
      return DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: pageSize,
          isDense: true,
          items: pageSizeOptions.map((size) {
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
        final padding = EdgeInsets.symmetric(
          horizontal: layout.resolve(compact: 12.0, medium: 16.0),
          vertical: layout.resolve(compact: 10.0, medium: 8.0),
        );

        return Container(
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
                          buildPageSizeDropdown(),
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
      },
    );
  }
}
