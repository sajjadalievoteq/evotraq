import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Step 1: Receiving reference and location details.
class ReceivingReferenceDetailsStep extends StatelessWidget {
  const ReceivingReferenceDetailsStep({
    super.key,
    required this.referenceController,
    required this.sourceGln,
    required this.receivingGln,
    required this.sourceGlnError,
    required this.receivingGlnError,
    required this.onSourceGlnChanged,
    required this.onReceivingGlnChanged,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.receivingAdviceController,
    required this.invoiceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.notesController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
  });

  final TextEditingController referenceController;
  final GLN? sourceGln;
  final GLN? receivingGln;
  final String? sourceGlnError;
  final String? receivingGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onReceivingGlnChanged;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController receivingAdviceController;
  final TextEditingController invoiceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
  final TextEditingController notesController;
  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final bool showPageHeader;
  final bool showReferenceSection;
  final bool showLocationSection;
  final bool showDocumentSection;

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
              'Receiving Reference Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture receiving reference, ship-from/received-at locations, and shipment details.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
          if (showReferenceSection)
            Gs1GroupCard(
              title: 'Receiving Reference',
              outlineColor: outline,
              child: Column(
                children: [
                  TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Receiving Reference *',
                      hintText: 'e.g., RECV-2026-0001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Received On'),
                    subtitle: Text(
                      eventTime != null
                          ? '${eventTime!.toLocal()}'.substring(0, 16)
                          : 'Now (at time of submission)',
                      style: TextStyle(
                        color: eventTime != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_calendar_outlined),
                          tooltip: 'Set event date & time',
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: eventTime ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (date == null || !context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                eventTime ?? DateTime.now(),
                              ),
                            );
                            if (time == null) return;
                            onEventTimeChanged(
                              DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              ),
                            );
                          },
                        ),
                        if (eventTime != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Reset to now',
                            onPressed: () => onEventTimeChanged(null),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (showLocationSection)
            Gs1GroupCard(
              title: 'Locations',
              outlineColor: outline,
              child: Column(
                children: [
                  GLNSelector(
                    label: 'Ship From Location',
                    hintText: 'Search and select source GLN',
                    initialValue: sourceGln,
                    isRequired: true,
                    errorText: sourceGlnError,
                    onChanged: onSourceGlnChanged,
                  ),
                  const SizedBox(height: 16),
                  GLNSelector(
                    label: 'Receiving Location (Received At)',
                    hintText: 'Search and select receiving GLN',
                    initialValue: receivingGln,
                    isRequired: true,
                    errorText: receivingGlnError,
                    onChanged: onReceivingGlnChanged,
                  ),
                ],
              ),
            ),
          if (showDocumentSection)
            Gs1GroupCard(
              title: 'Shipment Details (Optional)',
              outlineColor: outline,
              child: Column(
                children: [
                  TextField(
                    controller: purchaseOrderController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order Number',
                      hintText: 'e.g., PO-784511',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: despatchAdviceController,
                    decoration: const InputDecoration(
                      labelText: 'Despatch Advice Number',
                      hintText: 'e.g., DESADV-12001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: receivingAdviceController,
                    decoration: const InputDecoration(
                      labelText: 'Receiving Advice Number (RECADV)',
                      hintText: 'e.g., RECADV-2026-0042',
                      helperText:
                          'Optional — EDI Receiving Advice document number (if applicable)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inbox_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: invoiceController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      hintText: 'e.g., INV-45021',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.request_quote_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: billOfLadingController,
                    decoration: const InputDecoration(
                      labelText: 'Bill of Lading Number',
                      hintText: 'e.g., BOL-20260001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: carrierController,
                    decoration: const InputDecoration(
                      labelText: 'Carrier',
                      hintText: 'e.g., DHL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: trackingController,
                    decoration: const InputDecoration(
                      labelText: 'Tracking Number',
                      hintText: 'e.g., 1Z999AA10123456784',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Optional comments about this receipt',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

