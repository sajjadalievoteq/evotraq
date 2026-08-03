import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionMultiSelectField extends StatelessWidget {
  const SubscriptionMultiSelectField({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    required this.helperText,
  });

  final String name;
  final String label;
  final List<Map<String, String>> options;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: name,
      builder: (FormFieldState<List<String>> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            helperText: helperText,
            helperMaxLines: 1,
            errorText: field.errorText,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            helperStyle: const TextStyle(),
          ),
          child: Column(
            children: [
              if (field.value != null && field.value!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColorMapper.infoSoft(context),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColorMapper.infoColor(context)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: field.value!.map((value) {
                      final option = options.firstWhere(
                        (opt) => opt['value'] == value,
                        orElse: () => {'label': value, 'value': value},
                      );
                      return Chip(
                        label: Text(option['label']!),
                        onDeleted: () {
                          final newValue = List<String>.from(field.value!)
                            ..remove(value);
                          field.didChange(newValue.isEmpty ? null : newValue);
                        },
                        deleteIcon: TraqIcon(AppAssets.iconX, size: 16),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: TraqIcon(AppAssets.iconPlus),
                  label: Text(
                    field.value == null || field.value!.isEmpty
                        ? 'Select Event Types'
                        : 'Add More Event Types',
                  ),
                  onPressed: () => _showMultiSelectDialog(
                    context,
                    label,
                    options,
                    field.value ?? [],
                    (selectedValues) {
                      field.didChange(
                        selectedValues.isEmpty ? null : selectedValues,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<Map<String, String>> options,
    List<String> currentSelection,
    Function(List<String>) onSelectionChanged,
  ) {
    List<String> tempSelection = List.from(currentSelection);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = tempSelection.contains(option['value']);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelection.add(option['value']!);
                      } else {
                        tempSelection.remove(option['value']);
                      }
                    });
                  },
                  title: Text(
                    option['label']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: option['description'] != null
                      ? Text(
                          option['description']!,
                          style: TextStyle(
                            color: context.colors.textMuted,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                tempSelection.clear();
                setState(() {});
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
