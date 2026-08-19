import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_navigation.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_records.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/records/tatmeen_records_table.dart';

class TatmeenRecordsScreen extends StatefulWidget {
  const TatmeenRecordsScreen({
    super.key,
    required this.filter,
    this.embedded = false,
  });

  final RecordsFilter filter;
  final bool embedded;

  @override
  State<TatmeenRecordsScreen> createState() => _TatmeenRecordsScreenState();
}

class _TatmeenRecordsScreenState extends State<TatmeenRecordsScreen> {
  late final UseTatmeenRecords _records;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _records = UseTatmeenRecords(
      service: getIt<TatmeenIntegrationService>(),
      filter: widget.filter,
    )..load();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _records.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = AnimatedBuilder(
      animation: _records,
      builder: (context, _) => _buildBody(context),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(widget.filter.title)),
      drawer: const AppDrawer(),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.gutter),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: _header(context),
        ),
        const SizedBox(height: TraqSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: _filters(context),
        ),
        const SizedBox(height: TraqSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: _records.isLoading
              ? AppShimmer(
                  child: AppSkeletonBox(
                    width: 220,
                    height: 14,
                    color: AppShimmer.defaultBaseColor(context),
                  ),
                )
              : _records.isError
              ? const SizedBox.shrink()
              : Text(
                  _summaryText(),
                  style: context.text.bodySm.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
        ),

        Expanded(
          child: _records.isError && !_records.isLoading
              ? SubscriptionErrorView(
                  title: 'Unable to load sync records',
                  message: _records.error ?? 'Unknown error',
                  onRetry: _records.refetch,
                )
              : TatmeenRecordsTable(
                  records: _records.records,
                  isLoading: _records.isLoading,
                  isBusy: _records.isBusy,
                  onRetry: (record) => _records.retryRecord(record.id),
                ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => TatmeenNavigation.goBack(context),
          icon: const TraqIcon(AppAssets.iconChevronL, size: 18),
        ),
        const TraqIcon(AppAssets.iconHistory, size: 18),
        const SizedBox(width: TraqSpacing.sm),
        Expanded(
          child: Text(widget.filter.title, style: context.text.h2),
        ),
        OutlinedButton(
          onPressed: null,
          child: const Text('Export CSV'),
        ),
      ],
    );
  }

  Widget _filters(BuildContext context) {
    return Wrap(
      spacing: TraqSpacing.md,
      runSpacing: TraqSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _dateField(
          context,
          label: 'From Date',
          value: _records.fromDate,
          onChanged: (value) => value == null
              ? _records.setDraft(clearFrom: true)
              : _records.setDraft(fromDate: value),
        ),
        _dateField(
          context,
          label: 'To Date',
          value: _records.toDate,
          onChanged: (value) => value == null
              ? _records.setDraft(clearTo: true)
              : _records.setDraft(toDate: value),
        ),
        SizedBox(
          width: 240,
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Operation ID or type',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => _records.setDraft(search: value),
          ),
        ),
        SizedBox(
            height: 40,
            width: 90,
            child: FilledButton(onPressed: _records.apply, child: const Text('Apply'))),
        SizedBox(
          height: 40,

          child: TextButton(onPressed: () {
            _searchController.clear();
            _records.clear();
          }, child: const Text('Clear')),
        ),
      ],
    );
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return SizedBox(
      width: 180,
      height: 40,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(

            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: value == null
                ? const TraqIcon(AppAssets.iconClock, size: 14)
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () => onChanged(null),
                    icon: const TraqIcon(AppAssets.iconX, size: 16),
                  ),
          ),
          child: Text(
            value == null ? 'Select date' : DisplayDateUtils.dmy(value),
          ),
        ),
      ),
    );
  }

  String _summaryText() {
    final count = NumberFormat.decimalPattern().format(_records.total);
    final label = switch (_records.status) {
      TatmeenRecordsStatusFilter.all => 'records',
      TatmeenRecordsStatusFilter.successful => 'successful records',
      TatmeenRecordsStatusFilter.failed => 'failed records',
      TatmeenRecordsStatusFilter.pending => 'pending records',
    };
    return 'Showing $count $label · last 30 days';
  }
}

class TatmeenRecordsRouteScreen extends StatelessWidget {
  const TatmeenRecordsRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.layout.isDesktopUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(Constants.tatmeenIntegrationRoute);
        }
      });
      return const SizedBox.shrink();
    }
    final extra = GoRouterState.of(context).extra;
    return TatmeenRecordsScreen(filter: RecordsFilter.fromExtra(extra));
  }
}
