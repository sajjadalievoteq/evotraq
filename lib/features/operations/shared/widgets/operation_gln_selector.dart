import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

class OperationGlnSelector extends StatelessWidget {
  const OperationGlnSelector({
    super.key,
    required this.label,
    required this.gln,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.isRequired = true,
    this.readOnly = false,
    this.pickerCatalog,
  });

  final String label;
  final GLN? gln;
  final ValueChanged<GLN?> onChanged;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool readOnly;
  final List<GLN>? pickerCatalog;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          prefixIcon: TraqIcon(NavIcons.gln),
        ),
        child: Text(
          gln != null ? '${gln!.glnCode} — ${gln!.locationName}' : '—',
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    return GLNSelector(
      label: label,
      hintText: hintText,
      initialValue: gln,
      isRequired: isRequired,
      errorText: errorText,
      onChanged: onChanged,
      pickerCatalog: pickerCatalog,
    );
  }
}
