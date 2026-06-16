import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/list/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/list/object_event_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';

class ObjectEventsResultsList extends StatelessWidget {
  const ObjectEventsResultsList({
    super.key,
    required this.scrollController,
    this.selectedEventId,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onTapEvent,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final String? selectedEventId;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<ObjectEvent> onTapEvent;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
      builder: (context, state) {
        if (state.isListLoading && state.objectEvents.isEmpty) {
          return const Gs1ListLoadingShimmer();
        }

        if (state.listFetchError != null && state.objectEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(state.listFetchError!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRefresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.objectEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_note_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  state.filterAction != null ||
                          state.filterBizStep != null ||
                          state.filterDisposition != null ||
                          state.filterEPC != null ||
                          state.filterLocationGLN != null ||
                          state.filterSearchText != null
                      ? ObjectEventListUiConstants.emptyNoMatchSearch
                      : ObjectEventListUiConstants.emptyListTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollEndNotification &&
                n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              onLoadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(context.padding.top, 0, context.padding.top, 0),
              itemCount:
                  state.objectEvents.length + (state.isFetchingMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= state.objectEvents.length) {
                  return const Gs1ListLoadMoreIndicator();
                }
                final event = state.objectEvents[i];
                final id = event.eventId;
                return ObjectEventListItemCard(
                  key: ValueKey(id),
                  event: event,
                  isSelected: selectedEventId == id,
                  onTap: () => onTapEvent(event),
                );
              }, separatorBuilder: (BuildContext context, int index) { return state.objectEvents.length>index? SizedBox(height: 16,):SizedBox.shrink();  },
            ),
          ),
        );
      },
    );
  }
}
