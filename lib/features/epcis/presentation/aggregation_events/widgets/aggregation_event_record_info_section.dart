import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_record_info_bar.dart';

class AggregationEventRecordInfoSection extends StatelessWidget {
  const AggregationEventRecordInfoSection({
    super.key,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AggregationEventsCubit, AggregationEventsState,
        ({int count, bool hasMore})>(
      selector: (state) => (
        count: state.aggregationEvents.length,
        hasMore: state.hasMoreData,
      ),
      builder: (context, selected) {
        if (selected.count == 0 && !selected.hasMore) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            const SizedBox(height: Constants.spacing),
            Gs1ListRecordInfoBar(
              entityPlural: AggregationEventUiConstants.entityPluralEvents,
              loadedRecords: selected.count,
              hasMoreData: selected.hasMore,
              pageSize: pageSize,
              onPageSizeChanged: onPageSizeChanged,
              pageSizeOptions: AggregationEventUiConstants.pageSizeOptions,
            ),
          ],
        );
      },
    );
  }
}
