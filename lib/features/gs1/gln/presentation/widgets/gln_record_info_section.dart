import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_record_info_bar.dart';

class GlnRecordInfoSection extends StatelessWidget {
  const GlnRecordInfoSection({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GLNCubit, GLNState, ({int count, bool hasMore})>(
      selector: (state) => (count: state.glns.length, hasMore: state.hasMoreData),
      builder: (context, selected) {
        if (selected.count == 0) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(height: Constants.spacing),
            Gs1ListRecordInfoBar(
              entityPlural: GlnUiConstants.entityPluralGlns,
              loadedRecords: selected.count,
              hasMoreData: selected.hasMore,
              pageSize: pageSize,
              onPageSizeChanged: onPageSizeChanged,
              pageSizeOptions: GlnUiConstants.pageSizeOptions,
            ),
          ],
        );
      },
    );
  }
}
