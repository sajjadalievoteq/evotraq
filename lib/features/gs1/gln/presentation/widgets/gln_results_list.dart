import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_state.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/widgets/gln_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_empty_view.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
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
        if (current.listFetchError != null) return true;
        return current.status == GLNStatus.error &&
            current.error != null &&
            (previous.status != GLNStatus.error ||
                previous.error != current.error);
      },
      listener: (context, state) {
        if (state.listFetchError != null) {
          context.showError(state.listFetchError!);
          context.read<GLNCubit>().clearGlnListError();
          return;
        }
        if (state.status == GLNStatus.error && state.error != null) {
          context.showError(state.error!);
        }
      },
      buildWhen: (previous, current) =>
          previous.glns != current.glns ||
          previous.isGlnListLoading != current.isGlnListLoading ||
          previous.hasMoreData != current.hasMoreData ||
          previous.isFetchingMore != current.isFetchingMore ||
          previous.listFetchError != current.listFetchError ||
          previous.status != current.status,
      builder: (context, state) {
        if (state.glns.isEmpty &&
            (state.isGlnListLoading ||
                state.status == GLNStatus.initial)) {
          return const Gs1ListLoadingShimmer();
        }

        if (state.glns.isEmpty) {
          return _constrainedCenter(
            Gs1ListEmptyView(
              icon: Icons.location_off_outlined,
              title: GlnUiConstants.emptyListTitle,
              onClearFilters: onClearFilters,
            ),
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
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: 400,
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
                      const Gs1ListLoadMoreShimmer(),
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
