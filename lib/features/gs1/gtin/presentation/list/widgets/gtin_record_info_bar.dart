import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

import '../../../../../../core/consts/app_consts.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Constants.cardRadius),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hasMoreData
                ? 'Showing $loadedRecords+ GTINs (scroll for more)'
                : 'Showing all $loadedRecords GTINs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Row(
            children: [
              if (hasMoreData)
                Text(
                  'Loaded: ${(loadedRecords / pageSize).ceil()} batches',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: pageSize,
                items: GtinUiConstants.pageSizeOptions.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text('$size/batch'),
                  );
                }).toList(),
                onChanged: (newSize) {
                  if (newSize != null) onPageSizeChanged(newSize);
                },
                underline: const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

