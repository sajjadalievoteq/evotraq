import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_list_empty_view.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_list_loading_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_list_item_card.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class GtinResultsList extends StatelessWidget {
  const GtinResultsList({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onTapGtin,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onTapGtin;
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
    return BlocConsumer<GTINCubit, GTINState>(
      listenWhen: (previous, current) {
        if (current.listFetchError != null) return true;
        return current.status == GTINStatus.error;
      },
      listener: (context, state) {
        if (state.listFetchError != null) {
          debugPrint(
            '[GTIN UI] listFetchError (snackbar): ${state.listFetchError}',
          );
          debugPrint(
            '[GTIN UI] listFetchError status=${state.listFetchErrorStatusCode} body=${state.listFetchErrorBody}',
          );
          context.showError(state.listFetchError!);
          context.read<GTINCubit>().clearGtinListError();
          return;
        }
        if (state.status == GTINStatus.error) {
          debugPrint(
            '[GTIN UI] cubit error status (snackbar): ${state.error}',
          );
          context.showError(state.error ?? '');
        }
      },
      builder: (context, state) {
        if (state.gtins == null &&
            (state.isGtinListLoading || state.status == GTINStatus.initial)) {
          return const GtinListLoadingShimmer();
        }

        final gtins = state.gtins;
        if (gtins == null || gtins.isEmpty) {
          return _constrainedCenter(
            GtinListEmptyView(onClearFilters: onClearFilters),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is! ScrollUpdateNotification &&
                notification is! OverscrollNotification) {
              return false;
            }

            if (notification.metrics.extentAfter < 400 &&
                state.hasMoreData &&
                !state.isFetchingMore) {
              onLoadMore();
            }
            return false;
          },
          child: Scrollbar(
            controller: scrollController,
            interactive: true,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gtins.length +
                      ((state.hasMoreData && state.isFetchingMore) ? 1 : 0) +
                      1,
                  itemBuilder: (context, index) {
                    if (index < gtins.length) {
                      final gtin = gtins[index];
                      return _constrainedCenter(
                        RepaintBoundary(
                          child: GtinListItemCard(
                            gtin: gtin,
                            onTap: () => onTapGtin(gtin.gtinCode),
                          ),
                        ),
                      );
                    }

                    final loaderIndex = gtins.length;
                    final spacerIndex =
                        gtins.length + ((state.hasMoreData && state.isFetchingMore) ? 1 : 0);

                    if (index == loaderIndex &&
                        state.hasMoreData &&
                        state.isFetchingMore) {
                      return _constrainedCenter(
                        const GtinListLoadMoreShimmer(),
                      );
                    }

                    if (index == spacerIndex) {
                      return const SizedBox(height: Constants.spacing);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

