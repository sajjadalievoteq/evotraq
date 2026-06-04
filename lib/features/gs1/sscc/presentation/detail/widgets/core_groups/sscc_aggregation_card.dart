import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccAggregationCard extends StatefulWidget {
  const SsccAggregationCard({
    super.key,
    required this.borderColor,
    required this.sscc,
    this.aggregationLinks = const [],
    this.isReadOnly = true,
    this.onAddChild,
    this.onDisaggregate,
  });

  final Color borderColor;
  final SSCC? sscc;
  final List<SsccAggregationLink> aggregationLinks;
  final bool isReadOnly;
  final Future<bool> Function({
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  })? onAddChild;
  final Future<bool> Function({
    required int linkId,
    required String disaggregationEventId,
  })? onDisaggregate;

  @override
  State<SsccAggregationCard> createState() => _SsccAggregationCardState();
}

class _SsccAggregationCardState extends State<SsccAggregationCard> {
  final _childEpcController = TextEditingController();
  final _eventIdController = TextEditingController();
  String _childKind = 'SGTIN';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _childEpcController.dispose();
    _eventIdController.dispose();
    super.dispose();
  }

  Future<void> _submitAdd() async {
    if (widget.onAddChild == null || widget.sscc?.id == null) return;

    final childEpc = _childEpcController.text.trim();
    final eventId = _eventIdController.text.trim();
    if (childEpc.isEmpty || eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child EPC and aggregation event ID are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.onAddChild!(
      childEpc: childEpc,
      childKind: _childKind,
      aggregationEventId: eventId,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        _childEpcController.clear();
        _eventIdController.clear();
      }
    }
  }

  Future<void> _confirmDisaggregate(SsccAggregationLink link) async {
    if (widget.onDisaggregate == null || link.id == null) return;

    final eventController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disaggregate child'),
        content: TextField(
          controller: eventController,
          decoration: const InputDecoration(
            labelText: 'Disaggregation event ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disaggregate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    await widget.onDisaggregate!(
      linkId: link.id!,
      disaggregationEventId: eventController.text.trim(),
    );
    eventController.dispose();
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sscc == null) {
      return const SizedBox.shrink();
    }

    final sscc = widget.sscc!;
    final links = widget.aggregationLinks;
    final childEpcs = links.isNotEmpty
        ? links.map((l) => l.childEpc).toList()
        : [
            ...?sscc.childSgtins,
            ...?sscc.childSsccs,
          ];

    return Gs1GroupCard(
      title: 'Aggregation',
      outlineColor: widget.borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow('Parent SSCC', sscc.parentSsccCode),
          const SizedBox(height: 12),
          SgtinInfoRow('Scan-Visible SSCC', sscc.scanVisibleSsccCode),
          const SizedBox(height: 12),
          SgtinInfoRow('Child Count', sscc.childCount?.toString()),
          const SizedBox(height: 12),
          SgtinInfoRow('Total Leaf Count', sscc.totalLeafCount?.toString()),
          if (links.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Active Children',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...links.map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.childEpc,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                          Text(
                            link.childKind,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isReadOnly && link.active)
                      IconButton(
                        tooltip: 'Disaggregate',
                        onPressed: _isSubmitting
                            ? null
                            : () => _confirmDisaggregate(link),
                        icon: const Icon(Icons.link_off, size: 20),
                      ),
                  ],
                ),
              ),
            ),
          ] else if (childEpcs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Active Children',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...childEpcs.map(
              (epc) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  epc,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
          if (!widget.isReadOnly && widget.onAddChild != null) ...[
            const Divider(height: 24),
            Text(
              'Add child',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _childKind,
              decoration: const InputDecoration(
                labelText: 'Child kind',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'SGTIN', child: Text('SGTIN')),
                DropdownMenuItem(value: 'SSCC', child: Text('SSCC')),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (v) => setState(() => _childKind = v ?? 'SGTIN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _childEpcController,
              decoration: const InputDecoration(
                labelText: 'Child EPC URI',
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _eventIdController,
              decoration: InputDecoration(
                labelText: 'Aggregation event ID',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'Generate event ID',
                  icon: const Icon(Icons.bolt),
                  onPressed: _isSubmitting
                      ? null
                      : () => _eventIdController.text = const Uuid().v4(),
                ),
              ),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitAdd,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_link),
                label: const Text('Add child'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
