import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/sscc/bloc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_record_info_bar.dart';

class SsccRecordInfoSection extends StatelessWidget {
  const SsccRecordInfoSection({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SSCCCubit, SSCCState, ({int count, bool hasMore})>(
      selector: (state) => (count: state.ssccs.length, hasMore: state.hasMoreData),
      builder: (context, selected) {
        if (selected.count == 0 && !selected.hasMore) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const SizedBox(height: Constants.spacing),
            Gs1ListRecordInfoBar(
              entityPlural: SsccUiConstants.entityPluralSsccs,
              loadedRecords: selected.count,
              hasMoreData: selected.hasMore,
              pageSize: pageSize,
              onPageSizeChanged: onPageSizeChanged,
              pageSizeOptions: SsccUiConstants.pageSizeOptions,
            ),
          ],
        );
      },
    );
  }
}
