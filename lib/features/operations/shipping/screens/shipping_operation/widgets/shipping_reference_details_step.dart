import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

/// Step 1: shipping reference and location details.
class ShippingReferenceDetailsStep extends StatelessWidget {
  const ShippingReferenceDetailsStep({
    super.key,
    required this.referenceController,
    required this.sourceGln,
    required this.destinationGln,
    required this.sourceGlnError,
    required this.destinationGlnError,
    required this.onSourceGlnChanged,
    required this.onDestinationGlnChanged,
    required this.purchaseOrderController,
    required this.despatchAdviceController,
    required this.billOfLadingController,
    required this.carrierController,
    required this.trackingController,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.showPageHeader = true,
    this.showReferenceSection = true,
    this.showLocationSection = true,
    this.showDocumentSection = true,
  });

  final TextEditingController referenceController;
  final GLN? sourceGln;
  final GLN? destinationGln;
  final String? sourceGlnError;
  final String? destinationGlnError;
  final ValueChanged<GLN?> onSourceGlnChanged;
  final ValueChanged<GLN?> onDestinationGlnChanged;
  final TextEditingController purchaseOrderController;
  final TextEditingController despatchAdviceController;
  final TextEditingController billOfLadingController;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
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
              'Shipping Reference Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture shipping reference, origin, destination, and dispatch details.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
          if (showReferenceSection)
            Gs1GroupCard(
              title: 'Shipping Reference',
              outlineColor: outline,
              child: Column(
                children: [
                  TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Shipping Reference *',
                      hintText: 'e.g., SHIP-2026-0001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Event Date & Time'),
                    subtitle: Text(
                      eventTime != null
                          ? '${eventTime!.toLocal()}'.substring(0, 16)
                          : 'Now',
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
                    label: 'Ship To Location',
                    hintText: 'Search and select destination GLN',
                    initialValue: destinationGln,
                    isRequired: true,
                    errorText: destinationGlnError,
                    onChanged: onDestinationGlnChanged,
                  ),
                ],
              ),
            ),
          if (showDocumentSection)
            Gs1GroupCard(
              title: 'Shipping Details (Optional)',
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}


