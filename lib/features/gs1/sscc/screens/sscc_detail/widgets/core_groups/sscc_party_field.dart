import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

class SsccPartyField extends StatelessWidget {
  const SsccPartyField({
    required this.label,
    required this.selected,
    required this.storedCode,
    required this.onChanged,
    required this.isReadOnly,
    required this.pickerCatalog,
    super.key,
  });

  final String label;
  final GLN? selected;
  final String? storedCode;
  final ValueChanged<GLN?> onChanged;
  final bool isReadOnly;
  final List<GLN>? pickerCatalog;

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      final display = selected != null
          ? '${selected!.glnCode} – ${selected!.locationName}'
          : storedCode;
      return SgtinInfoRow(label, display);
    }
    return GLNSelector(
      label: label,
      hintText: 'Search and select $label',
      initialValue: selected,
      onChanged: onChanged,
      pickerCatalog: pickerCatalog,
    );
  }
}
