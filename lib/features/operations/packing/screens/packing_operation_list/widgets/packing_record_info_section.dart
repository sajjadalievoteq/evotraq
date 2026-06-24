import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_record_info_bar.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_ui_constants.dart';

class PackingRecordInfoSection extends StatelessWidget {
  const PackingRecordInfoSection({
    super.key,
    required this.loadedRecords,
    required this.filteredRecords,
    this.totalRecords = 0,
  });

  final int loadedRecords;
  final int filteredRecords;
  final int totalRecords;

  @override
  Widget build(BuildContext context) {
    if (loadedRecords == 0) return const SizedBox.shrink();

    final showingFiltered = filteredRecords != loadedRecords;
    final displayed = showingFiltered ? filteredRecords : loadedRecords;
    final hasMore = totalRecords > loadedRecords;
    final pageSize = Gs1ListPageSizes.defaults.first;

    return Column(
      children: [
        const SizedBox(height: Constants.spacing),
        Gs1ListRecordInfoBar(
          entityPlural: PackingUiConstants.entityPluralOperations,
          loadedRecords: displayed,
          hasMoreData: hasMore,
          pageSize: pageSize,
          onPageSizeChanged: (_) {},
          pageSizeOptions: [pageSize],
        ),
      ],
    );
  }
}
