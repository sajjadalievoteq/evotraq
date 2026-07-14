import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_reason_options.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_auto_reference_notice.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_event_time_tile.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';

class UpdateStatusReferenceDetailsStep extends StatelessWidget {
  const UpdateStatusReferenceDetailsStep({
    super.key,
    required this.locationGln,
    required this.locationGlnError,
    required this.onLocationGlnChanged,
    required this.selectedDisposition,
    required this.onDispositionChanged,
    required this.reasonController,
    required this.selectedReason,
    required this.onReasonChanged,
    required this.commentsController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
  });

  final GLN? locationGln;
  final String? locationGlnError;
  final ValueChanged<GLN?> onLocationGlnChanged;
  final UpdateStatusDisposition? selectedDisposition;
  final ValueChanged<UpdateStatusDisposition?> onDispositionChanged;
  final TextEditingController reasonController;
  final String? selectedReason;
  final ValueChanged<String?> onReasonChanged;
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
              'Update Status Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Specify the location and new status for the selected items.',
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
                  operationLabel: 'Update Status',
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
              hintText: 'Search and select update status location',
              gln: locationGln,
              errorText: locationGlnError,
              onChanged: onLocationGlnChanged,
            ),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Status & Reason',
            showRequiredStar: true,
            outlineColor: outline,
            child: Column(
              children: [
                DropdownButtonFormField<UpdateStatusDisposition>(
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDisposition,
                  items: UpdateStatusDisposition.values
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
                KeyedSubtree(
                  key: ValueKey(_reasonFieldKey()),
                  child: _buildReasonField(),
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

  String _reasonFieldKey() {
    if (selectedDisposition == UpdateStatusDisposition.sample) return 'sample';
    if (selectedDisposition == UpdateStatusDisposition.damaged) return 'damaged';
    return 'freetext';
  }

  Widget _buildReasonField() {
    if (selectedDisposition == UpdateStatusDisposition.sample) {
      return _reasonDropdown(
        key: const ValueKey('sample-reason'),
        options: SampleReasonOptions.values,
        hint: 'Select a sample reason',
      );
    }

    if (selectedDisposition == UpdateStatusDisposition.damaged) {
      return _reasonDropdown(
        key: const ValueKey('damaged-reason'),
        options: DamagedReasonOptions.values,
        hint: 'Select a damage reason',
      );
    }

    return TextField(
      key: const ValueKey('freetext-reason'),
      controller: reasonController,
      decoration: const InputDecoration(
        labelText: 'Reason (optional)',
        hintText: 'e.g. Item lost during transit',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _reasonDropdown({
    required Key key,
    required List<String> options,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      key: key,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Reason *',
        border: OutlineInputBorder(),
      ),
      value: options.contains(selectedReason) ? selectedReason : null,
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: options
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(
                r,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => options
          .map(
            (r) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                r,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onReasonChanged,
    );
  }
}
