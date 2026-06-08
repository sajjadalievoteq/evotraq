import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/widgets/sgtin_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_empty_view.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class SgtinResultsList extends StatelessWidget {
  const SgtinResultsList({
    super.key,
    required this.scrollController,
    this.selectedSgtinId,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onTapSgtin,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final String? selectedSgtinId;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onTapSgtin;
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
    return BlocConsumer<SGTINCubit, SGTINState>(
      listenWhen: (previous, current) =>
          current.status == SGTINStatus.error && previous.status != SGTINStatus.error,
      listener: (context, state) {
        if (state.error != null) {
          context.showError(state.error!);
        }
      },
      builder: (context, state) {
        final isInitialLoad =
            state.sgtins == null && state.status == SGTINStatus.loading;

        if (isInitialLoad) {
          return const Gs1ListLoadingShimmer();
        }

        final sgtins = state.sgtins;
        if (sgtins == null || sgtins.isEmpty) {
          return _constrainedCenter(
            Gs1ListEmptyView(
              icon: Icons.qr_code_2,
              title: SgtinUiConstants.emptyListTitle,
              onClearFilters: onClearFilters,
            ),
          );
        }

        final isFetchingMore =
            state.status == SGTINStatus.loading && sgtins.isNotEmpty;

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
                itemCount: sgtins.length +
                    (state.hasMoreData && isFetchingMore ? 1 : 0) +
                    1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Constants.spacing),
                itemBuilder: (context, index) {
                  if (index < sgtins.length) {
                    final sgtin = sgtins[index];
                    return _constrainedCenter(
                      RepaintBoundary(
                        child: SgtinListItemCard(
                          sgtin: sgtin,
                          isSelected:
                              (sgtin.id ?? sgtin.serialNumber) == selectedSgtinId,
                          onTap: () =>
                              onTapSgtin(sgtin.id ?? sgtin.serialNumber),
                        ),
                      ),
                    );
                  }

                  final loaderIndex = sgtins.length;
                  final spacerIndex =
                      sgtins.length + (state.hasMoreData && isFetchingMore ? 1 : 0);

                  if (index == loaderIndex && state.hasMoreData && isFetchingMore) {
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
