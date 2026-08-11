import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';

class AggregationCbvDropdownField extends StatelessWidget {
  const AggregationCbvDropdownField({
    required this.items,
    required this.selectedValue,
    required this.epcisVersion,
    required this.isBusinessStep,
    required this.label,
    required this.hint,
    required this.helperText,
    required this.tooltip,
    required this.emptyMessage,
    required this.disabled,
    required this.onChanged,
    required this.onDefaultSelected,
    super.key,
  });

  final List<CbvVocabularyItem> items;
  final String? selectedValue;
  final EPCISVersion epcisVersion;
  final bool isBusinessStep;
  final String label;
  final String hint;
  final String helperText;
  final String tooltip;
  final String emptyMessage;
  final bool disabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onDefaultSelected;

  @override
  Widget build(BuildContext context) {
    if (!disabled && items.isEmpty) {
      return Text(emptyMessage, style: const TextStyle(color: Colors.grey));
    }

    final selectable = items.map((item) => _format(item.urn)).toList();
    final value = selectable.contains(selectedValue)
        ? selectedValue
        : selectable.firstOrNull;
    if (value != null && value != selectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onDefaultSelected(value);
      });
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: hint,
        helperText: helperText,
        suffixIcon: Tooltip(
          message: tooltip,
          child: const TraqIcon(AppAssets.iconInfo, size: 16),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: _format(item.urn),
          child: Tooltip(message: item.urn, child: Text(item.label)),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a ${isBusinessStep ? 'business step' : 'disposition'}';
        }
        return null;
      },
      onChanged: disabled
          ? null
          : (value) {
              if (value != null) onChanged(value);
            },
    );
  }

  String _format(String urn) {
    final version = epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';
    return isBusinessStep
        ? CbvVocabularyFormatter.formatBizStep(version, urn)
        : CbvVocabularyFormatter.formatDisposition(version, urn);
  }
}
