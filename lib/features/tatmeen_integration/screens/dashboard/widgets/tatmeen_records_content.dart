import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_records.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/records/tatmeen_records_table.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_records_filters.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_records_header.dart';

class TatmeenRecordsContent extends StatelessWidget {
  const TatmeenRecordsContent({
    super.key,
    required this.records,
    required this.searchController,
    required this.title,
    required this.summaryText,
  });

  final UseTatmeenRecords records;
  final TextEditingController searchController;
  final String title;
  final String summaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.gutter),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: TatmeenRecordsHeader(title: title),
        ),
        const SizedBox(height: TraqSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: TatmeenRecordsFilters(
            records: records,
            searchController: searchController,
          ),
        ),
        const SizedBox(height: TraqSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: records.isLoading
              ? AppShimmer(
                  child: AppSkeletonBox(
                    width: 220,
                    height: 14,
                    color: AppShimmer.defaultBaseColor(context),
                  ),
                )
              : records.isError
              ? const SizedBox.shrink()
              : Text(
                  summaryText,
                  style: context.text.bodySm.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
        ),
        Expanded(
          child: records.isError && !records.isLoading
              ? SubscriptionErrorView(
                  title: 'Unable to load sync records',
                  message: records.error ?? 'Unknown error',
                  onRetry: records.refetch,
                )
              : TatmeenRecordsTable(
                  records: records.records,
                  isLoading: records.isLoading,
                  isBusy: records.isBusy,
                  onRetry: (record) => records.retryRecord(record.operationId),
                ),
        ),
      ],
    );
  }
}
