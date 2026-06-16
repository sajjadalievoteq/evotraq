import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_empty_view.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class AggregationEventsResultsList extends StatelessWidget {
  const AggregationEventsResultsList({
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
  final ValueChanged<AggregationEvent> onTapEvent;
  final VoidCallback onLoadMore;

  Widget _constrainedCenter(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.sectionMaxWidth),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AggregationEventsCubit, AggregationEventsState>(
      listenWhen: (prev, curr) =>
          curr.status == AggregationEventsStatus.error &&
          prev.status != AggregationEventsStatus.error &&
          curr.listFetchError != null,
      listener: (context, state) {
        if (state.listFetchError != null) {
          context.showError(state.listFetchError!);
        }
      },
      builder: (context, state) {
        final isInitialLoad =
            state.aggregationEvents.isEmpty && state.isListLoading;

        if (isInitialLoad) {
          return const Gs1ListLoadingShimmer();
        }

        if (state.aggregationEvents.isEmpty) {
          return _constrainedCenter(
            Gs1ListEmptyView(
              icon: Icons.layers_outlined,
              title: AggregationEventUiConstants.emptyListTitle,
              onClearFilters: onClearFilters,
            ),
          );
        }

        final isFetchingMore =
            state.isFetchingMore && state.aggregationEvents.isNotEmpty;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is! ScrollUpdateNotification &&
                notification is! OverscrollNotification) {
              return false;
            }
            if (notification.metrics.extentAfter < 400 &&
                state.hasMoreData &&
                !isFetchingMore) {
              onLoadMore();
            }
            return false;
          },
          child: Scrollbar(
            controller: scrollController,
            interactive: true,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  left: context.padding.left,
                  right: context.padding.left,
                ),
                itemCount: state.aggregationEvents.length +
                    (state.hasMoreData && isFetchingMore ? 1 : 0) +
                    1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Constants.spacing),
                itemBuilder: (context, index) {
                  if (index < state.aggregationEvents.length) {
                    final event = state.aggregationEvents[index];
                    final isSelected = event.id == selectedEventId ||
                        event.eventId == selectedEventId;
                    return _constrainedCenter(
                      RepaintBoundary(
                        child: AggregationEventListItemCard(
                          event: event,
                          isSelected: isSelected,
                          onTap: () => onTapEvent(event),
                        ),
                      ),
                    );
                  }

                  final loaderIndex = state.aggregationEvents.length;
                  final spacerIndex = state.aggregationEvents.length +
                      (state.hasMoreData && isFetchingMore ? 1 : 0);

                  if (index == loaderIndex &&
                      state.hasMoreData &&
                      isFetchingMore) {
                    return _constrainedCenter(const Gs1ListLoadMoreIndicator());
                  }

                  if (index == spacerIndex) {
                    return const SizedBox(height: Constants.spacing);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
