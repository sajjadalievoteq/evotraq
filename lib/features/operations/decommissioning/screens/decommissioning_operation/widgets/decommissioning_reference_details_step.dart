import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_disposition.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_auto_reference_notice.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_event_time_tile.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';

class DecommissioningReferenceDetailsStep extends StatelessWidget {
  const DecommissioningReferenceDetailsStep({
    super.key,
    required this.locationGln,
    required this.locationGlnError,
    required this.onLocationGlnChanged,
    required this.selectedDisposition,
    required this.onDispositionChanged,
    required this.reasonController,
    required this.commentsController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
  });

  final GLN? locationGln;
  final String? locationGlnError;
  final ValueChanged<GLN?> onLocationGlnChanged;
  final DecommissioningDisposition? selectedDisposition;
  final ValueChanged<DecommissioningDisposition?> onDispositionChanged;
  final TextEditingController reasonController;
  final TextEditingController commentsController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPageHeader) ...[
            const Text(
              'Decommissioning Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Specify location, disposition, and reason for retiring items from the supply chain.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
          Gs1GroupCard(
            title: 'Operation Reference',
            outlineColor: outline,
            child: Column(
              children: [
                const OperationAutoReferenceNotice(
                  operationLabel: 'Decommissioning',
                ),
                OperationEventTimeTile(
                  eventTime: eventTime,
                  onEventTimeChanged: onEventTimeChanged,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Location',
            showRequiredStar: true,
            outlineColor: outline,
            child: OperationGlnSelector(
              label: 'Location GLN',
              hintText: 'Search and select decommissioning location',
              gln: locationGln,
              errorText: locationGlnError,
              onChanged: onLocationGlnChanged,
            ),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Disposition & Reason',
            outlineColor: outline,
            child: Column(
              children: [
                DropdownButtonFormField<DecommissioningDisposition>(
                  decoration: const InputDecoration(
                    labelText: 'Disposition *',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDisposition,
                  items: DecommissioningDisposition.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.label),
                        ),
                      )
                      .toList(),
                  onChanged: onDispositionChanged,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    hintText: 'e.g. Product expired, damaged in transit',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Comments (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
