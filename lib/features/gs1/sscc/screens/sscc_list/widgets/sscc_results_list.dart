import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_load_more_indicator.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/constrained_section_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_state.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_status.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_list/widgets/sscc_list_item_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';

class SsccResultsList extends StatelessWidget {
  const SsccResultsList({
    super.key,
    required this.scrollController,
    this.selectedSsccCode,
    required this.onRefresh,
    required this.onClearFilters,
    required this.hasActiveFilters,
    this.onCreate,
    required this.onTapSscc,
    required this.onRowMenuAction,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final String? selectedSsccCode;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;
  final VoidCallback? onCreate;
  final ValueChanged<String> onTapSscc;
  final void Function(SSCC sscc, String action) onRowMenuAction;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SSCCCubit, SSCCState>(
      listenWhen: (previous, current) =>
          current.status == SSCCStatus.error &&
          previous.status != SSCCStatus.error,
      listener: (context, state) {
        if (state.error != null) {
          context.showError(userFacingSsccErrorMessage(state.error));
        }
      },
      builder: (context, state) {
        final isInitialLoad =
            state.ssccs.isEmpty && state.status == SSCCStatus.loading;

        if (isInitialLoad) {
          return const Gs1ListLoadingShimmer();
        }

        if (state.ssccs.isEmpty) {
          return ConstrainedSectionContent(
            child: AppEmptyState(
              iconAsset: NavIcons.sscc,
              title: SsccUiConstants.emptyListTitle,
              subtitle: SsccUiConstants.emptyListSubtitle,
              filteredTitle: 'No results found',
              filteredSubtitle: SsccUiConstants.emptyNoMatchSearch,
              hasItems: hasActiveFilters,
              hasActiveFilters: hasActiveFilters,
              onClearFilters: onClearFilters,
              primaryActionLabel: hasActiveFilters
                  ? null
                  : SsccUiConstants.emptyAddAction,
              primaryActionIconAsset: hasActiveFilters
                  ? null
                  : AppAssets.iconPlus,
              onPrimaryAction: hasActiveFilters ? null : onCreate,
            ),
          );
        }

        final isFetchingMore =
            state.status == SSCCStatus.loading && state.ssccs.isNotEmpty;

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
                itemCount:
                    state.ssccs.length +
                    (state.hasMoreData && isFetchingMore ? 1 : 0) +
                    1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Constants.spacing),
                itemBuilder: (context, index) {
                  if (index < state.ssccs.length) {
                    final sscc = state.ssccs[index];
                    return ConstrainedSectionContent(
                      child: RepaintBoundary(
                        child: SsccListItemCard(
                          sscc: sscc,
                          isSelected: sscc.ssccCode == selectedSsccCode,
                          onTap: () => onTapSscc(sscc.ssccCode),
                          onMenuSelected: (action) =>
                              onRowMenuAction(sscc, action),
                        ),
                      ),
                    );
                  }

                  final loaderIndex = state.ssccs.length;
                  final spacerIndex =
                      state.ssccs.length +
                      (state.hasMoreData && isFetchingMore ? 1 : 0);

                  if (index == loaderIndex &&
                      state.hasMoreData &&
                      isFetchingMore) {
                    return ConstrainedSectionContent(
                      child: const Gs1ListLoadMoreIndicator(),
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
