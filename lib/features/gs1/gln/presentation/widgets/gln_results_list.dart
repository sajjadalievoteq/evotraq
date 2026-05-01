import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_list_empty_view.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_list_loading_shimmer.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class GlnResultsList extends StatelessWidget {
  const GlnResultsList({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onTapGln,
    required this.onRowMenuAction,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onTapGln;
  final void Function(GLN gln, String action) onRowMenuAction;
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
    return BlocConsumer<GLNCubit, GLNState>(
      listenWhen: (previous, current) {
        return current.status == GLNStatus.error &&
            current.error != null &&
            (previous.status != GLNStatus.error ||
                previous.error != current.error);
      },
      listener: (context, state) {
        context.showError(state.error!);
      },
      builder: (context, state) {
        final loadingInitial = state.glns.isEmpty &&
            (state.status == GLNStatus.loading ||
                state.status == GLNStatus.initial);

        if (loadingInitial) {
          return const GlnListLoadingShimmer();
        }

        if (state.glns.isEmpty) {
          return _constrainedCenter(
            GlnListEmptyView(onClearFilters: onClearFilters),
          );
        }

        final glns = state.glns;

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
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: glns.length +
                    ((state.hasMoreData && state.isFetchingMore) ? 1 : 0) +
                    1,
                itemBuilder: (context, index) {
                  if (index < glns.length) {
                    final gln = glns[index];
                    return _constrainedCenter(
                      RepaintBoundary(
                        child: GlnListItemCard(
                          gln: gln,
                          onTap: () => onTapGln(gln.glnCode),
                          onMenuSelected: (action) =>
                              onRowMenuAction(gln, action),
                        ),
                      ),
                    );
                  }

                  final loaderIndex = glns.length;
                  final spacerIndex = glns.length +
                      ((state.hasMoreData && state.isFetchingMore) ? 1 : 0);

                  if (index == loaderIndex &&
                      state.hasMoreData &&
                      state.isFetchingMore) {
                    return _constrainedCenter(
                      const GlnListLoadMoreShimmer(),
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
        );
      },
    );
  }
}
