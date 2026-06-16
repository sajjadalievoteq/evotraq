import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_action_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

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


  static const _dateFormat = 'MMM dd, yyyy HH:mm:ss';

  String _fmt(DateTime? dt) => dt == null
      ? '—'
      : DateFormat(_dateFormat).format(dt.toLocal());

  String _epcisVersionLabel(EPCISVersion? version) {
    switch (version) {
      case EPCISVersion.v1_3:
        return '1.3';
      case EPCISVersion.v2_0:
        return '2.0';
      case null:
        return '2.0';
    }
  }

  Widget _field(String label, String? value, {bool monospace = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 4),
          GestureDetector(
            onLongPress: value == null || value == '—'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: value));
                    context.showSuccess('Copied to clipboard');
                  },
            child: Text(
              value ?? '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: monospace ? 'monospace' : null,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwaitingPane() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Select an event from the list',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContent(AggregationEvent event) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionIdentification,
            outlineColor: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field('Event ID', event.eventId, monospace: true),
                    ),
                    const SizedBox(width: 12),
                    AggregationEventActionChip(action: event.action),
                  ],
                ),
                _field('Database ID', event.id),
                _field('EPCIS Version', _epcisVersionLabel(event.epcisVersion)),
                _field('Event Time', _fmt(event.eventTime)),
                _field('Record Time', _fmt(event.recordTime)),
                _field('Time Zone Offset', event.eventTimeZone),
              ],
            ),
          ),

          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionHierarchy,
            outlineColor: AggregationEventActionChip.colorFor(event.action),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('Parent EPC / SSCC', event.parentID, monospace: true),
                const SizedBox(height: 4),
                Text(
                  'Child EPCs (${event.childEPCs.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 6),
                if (event.childEPCs.isEmpty)
                  const Text('—')
                else
                  ...event.childEPCs.map(
                    (epc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: epc));
                          context.showSuccess('Copied to clipboard');
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                epc,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionLocation,
            outlineColor: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(
                  'Business Location',
                  event.businessLocation?.locationName ??
                      event.businessLocation?.glnCode,
                  monospace: event.businessLocation?.locationName == null,
                ),
                _field(
                  'Read Point',
                  event.readPoint?.locationName ?? event.readPoint?.glnCode,
                  monospace: event.readPoint?.locationName == null,
                ),
              ],
            ),
          ),

          Gs1GroupCard(
            title: AggregationEventUiConstants.sectionBizStep,
            outlineColor: Colors.deepPurple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(
                  'Business Step',
                  AggregationEventUiConstants.friendlyBizStep(
                      event.businessStep),
                ),
                _field(
                  'Disposition',
                  AggregationEventUiConstants.friendlyDisposition(
                      event.disposition),
                ),
                if (event.sourceList != null && event.sourceList!.isNotEmpty)
                  _field('Sources',
                      event.sourceList!.map((e) => e.toString()).join(', ')),
                if (event.destinationList != null &&
                    event.destinationList!.isNotEmpty)
                  _field(
                      'Destinations',
                      event.destinationList!
                          .map((e) => e.toString())
                          .join(', ')),
              ],
            ),
          ),

          if ((event.extensions != null && event.extensions!.isNotEmpty) ||
              (event.bizData != null && event.bizData!.isNotEmpty))
            Gs1GroupCard(
              title: AggregationEventUiConstants.sectionExtensions,
              outlineColor: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.bizData != null)
                    ...event.bizData!.entries.map(
                      (e) => _field(e.key, e.value.toString()),
                    ),
                  if (event.extensions != null)
                    ...event.extensions!.entries.map(
                      (e) => _field(e.key, e.value.toString()),
                    ),
                ],
              ),
            ),

          const SizedBox(height: Constants.spacing * 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (widget.awaitingListSelection) {
      body = _buildAwaitingPane();
    } else if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_event == null) {
      body = const Center(child: Text('Event not found'));
    } else {
      body = _buildContent(_event!);
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
