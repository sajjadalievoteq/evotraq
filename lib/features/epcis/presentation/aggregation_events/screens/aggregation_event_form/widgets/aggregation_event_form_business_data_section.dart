import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class AggregationEventFormBusinessDataSection extends StatelessWidget {
  const AggregationEventFormBusinessDataSection({
    super.key,
    required this.bizDataControllers,
    required this.onAddBizDataField,
    required this.onRemoveBizDataField,
  });

  final List<MapEntry<TextEditingController, TextEditingController>>
      bizDataControllers;
  final VoidCallback onAddBizDataField;
  final ValueChanged<int> onRemoveBizDataField;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Business Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bizDataControllers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No custom business data added. Tap "Add Business Data" to include extra key-value context.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ...bizDataControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controllers.key,
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Key required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: controllers.value,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Value required' : null,
                    ),
                  ),
                  IconButton(
                    icon: const TraqIcon(AppAssets.iconTrash, color: Colors.red, size: 20),
                    onPressed: () => onRemoveBizDataField(index),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onAddBizDataField,
            icon: const TraqIcon(AppAssets.iconPlus),
            label: const Text('Add Business Data'),
          ),
        ],
      ),
    );
  }
}