part of '../tatmeen_records_screen.dart';

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
                  onRetry: (record) => records.retryRecord(record.id),
                ),
        ),
      ],
    );
  }
}
