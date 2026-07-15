import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_event_detail_content.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_detail/widgets/aggregation_event_detail_skeleton.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';

class AggregationEventDetailScreen extends StatefulWidget {
  const AggregationEventDetailScreen({
    super.key,
    this.eventId,
    this.embedded = false,
    this.awaitingListSelection = false,
    this.onEmbeddedActionSuccess,
  });

  final String? eventId;
  final bool embedded;
  final bool awaitingListSelection;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<AggregationEventDetailScreen> createState() =>
      _AggregationEventDetailScreenState();
}

class _AggregationEventDetailScreenState
    extends State<AggregationEventDetailScreen> {
  AggregationEvent? _event;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) _load();
  }

  @override
  void didUpdateWidget(covariant AggregationEventDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId && widget.eventId != null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.eventId == null) return;
    setState(() => _loading = true);
    try {
      final event = await context
          .read<AggregationEventsCubit>()
          .getAggregationEventById(widget.eventId!);
      if (mounted) setState(() => _event = event);
    } catch (e) {
      if (mounted) context.showError('Failed to load event: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      return BlocBuilder<AggregationEventsCubit, AggregationEventsState>(
        buildWhen: (prev, curr) =>
            prev.isListLoading != curr.isListLoading ||
            prev.status != curr.status,
        builder: (context, state) {
          final listLoading = state.isListLoading ||
              state.status == AggregationEventsStatus.initial;
          final body = listLoading
              ? const AggregationEventDetailSkeleton()
              : AppEmptyDetail(
                  title: AggregationEventUiConstants.awaitingSelectionTitle,
                  subtitle:
                      AggregationEventUiConstants.awaitingSelectionSubtitle,
                  iconAsset: NavIcons.aggregationEvents,
                );
          return Gs1MasterDataDetailScaffold(
            embedded: widget.embedded,
            title: AggregationEventUiConstants.appBarManagement,
            body: body,
          );
        },
      );
    }

    Widget body;
    if (_loading) {
      body = const AggregationEventDetailSkeleton();
    } else if (_event == null) {
      body = const Center(child: Text('Event not found'));
    } else {
      body = AggregationEventDetailContent(event: _event!);
    }

    return Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: _event == null
          ? AggregationEventUiConstants.appBarManagement
          : 'Aggregation Event',
      body: body,
    );
  }
}
