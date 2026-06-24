import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';

class ObjectEventBatchImportManualTab extends StatelessWidget {
  const ObjectEventBatchImportManualTab({
    super.key,
    required this.formKey,
    required this.selectedAction,
    required this.onActionChanged,
    required this.businessStepController,
    required this.dispositionController,
    required this.businessLocationController,
    required this.readPointController,
    required this.epcController,
    required this.epcList,
    required this.onAddEpc,
    required this.onRemoveEpc,
    required this.lotController,
    required this.onAddManualEvent,
    required this.pendingEvents,
  });

  final GlobalKey<FormState> formKey;
  final String selectedAction;
  final ValueChanged<String> onActionChanged;
  final TextEditingController businessStepController;
  final TextEditingController dispositionController;
  final TextEditingController businessLocationController;
  final TextEditingController readPointController;
  final TextEditingController epcController;
  final List<String> epcList;
  final VoidCallback onAddEpc;
  final ValueChanged<String> onRemoveEpc;
  final TextEditingController lotController;
  final VoidCallback onAddManualEvent;
  final List<ObjectEvent> pendingEvents;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Action *',
                        border: OutlineInputBorder(),
                      ),
                      items: ['ADD', 'OBSERVE', 'DELETE']
                          .map(
                            (action) => DropdownMenuItem(
                              value: action,
                              child: Text(action),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onActionChanged(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: businessStepController,
                      decoration: const InputDecoration(
                        labelText: 'Business Step *',
                        hintText:
                            'e.g., urn:epcglobal:cbv:bizstep:commissioning',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Business step is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dispositionController,
                      decoration: const InputDecoration(
                        labelText: 'Disposition *',
                        hintText: 'e.g., urn:epcglobal:cbv:disp:active',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Disposition is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: businessLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Business Location GLN',
                        hintText: 'e.g., 6290360400006',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: readPointController,
                      decoration: const InputDecoration(
                        labelText: 'Read Point GLN',
                        hintText: 'e.g., 6290360400006',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EPCs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: epcController,
                            decoration: const InputDecoration(
                              labelText: 'EPC',
                              hintText:
                                  'URI: urn:epc:id:sgtin:5415062.32581.70007488444899\nGS1: (01)05415062325810(21)70007488444899',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => onAddEpc(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: onAddEpc,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    if (epcList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Added EPCs:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: epcList
                            .map(
                              (epc) => Chip(
                                label: Text(epc),
                                onDeleted: () => onRemoveEpc(epc),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instance/Lot Master Data (ILMD)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: lotController,
                      decoration: const InputDecoration(
                        labelText: 'Lot Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: epcList.isNotEmpty ? onAddManualEvent : null,
                child: const Text('Add to Batch'),
              ),
            ),
            if (pendingEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Events: ${pendingEvents.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pendingEvents.take(5).map(
                            (event) => ListTile(
                              title: Text(
                                '${event.action}: ${event.epcList?.first ?? 'No EPC'}',
                              ),
                              subtitle: Text(
                                event.businessStep ?? 'No business step',
                              ),
                              dense: true,
                            ),
                          ),
                      if (pendingEvents.length > 5)
                        Text('... and ${pendingEvents.length - 5} more'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
