import 'package:flutter/material.dart';

class UpdateStatusReasonDropdown extends StatelessWidget {
  const UpdateStatusReasonDropdown({
    super.key,
    required this.options,
    required this.selectedReason,
    required this.hint,
    required this.onChanged,
  });

  final List<String> options;
  final String? selectedReason;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Reason *',
        border: OutlineInputBorder(),
      ),
      value: options.contains(selectedReason) ? selectedReason : null,
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: options
          .map(
            (reason) => DropdownMenuItem(
              value: reason,
              child: Text(reason, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => options
          .map(
            (reason) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(reason, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
