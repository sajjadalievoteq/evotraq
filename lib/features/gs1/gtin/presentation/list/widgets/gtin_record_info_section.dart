import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_record_info_bar.dart';

import '../../../../../../core/consts/app_consts.dart';

class GtinRecordInfoSection extends StatelessWidget {
  const GtinRecordInfoSection({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GTINCubit, GTINState, ({int? count, bool hasMore})>(
      selector: (state) => (count: state.gtins?.length, hasMore: state.hasMoreData),
      builder: (context, selected) {
        final count = selected.count;
        if (count == null) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: Constants.spacing,
            ),
            GtinRecordInfoBar(
              loadedRecords: count,
              hasMoreData: selected.hasMore,
              pageSize: pageSize,
              onPageSizeChanged: onPageSizeChanged,
            ),
          ],
        );
      },
    );
  }
}

