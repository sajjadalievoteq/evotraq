import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_record_info_bar.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';

class CommissioningRecordInfoSection extends StatelessWidget {
  const CommissioningRecordInfoSection({
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
    if (loadedRecords == 0) return const SizedBox.shrink();

    final options = CommissioningUiConstants.pageSizeOptions;
    final effectivePageSize =
        options.contains(pageSize) ? pageSize : options.first;

    return Column(
      children: [
        const SizedBox(height: Constants.spacing),
        Gs1ListRecordInfoBar(
          entityPlural: CommissioningUiConstants.entityPluralOperations,
          loadedRecords: loadedRecords,
          hasMoreData: hasMoreData,
          pageSize: effectivePageSize,
          onPageSizeChanged: onPageSizeChanged,
          pageSizeOptions: options,
        ),
      ],
    );
  }
}
