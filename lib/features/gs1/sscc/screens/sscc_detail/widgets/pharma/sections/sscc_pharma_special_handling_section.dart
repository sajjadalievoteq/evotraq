import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaSpecialHandlingSection extends StatelessWidget {
  const SsccPharmaSpecialHandlingSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.fragile,
    required this.onFragileChanged,
    required this.doNotStack,
    required this.onDoNotStackChanged,
    required this.thisSideUp,
    required this.onThisSideUpChanged,
    required this.specialHandlingInstructionsController,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool fragile;
  final ValueChanged<bool> onFragileChanged;
  final bool doNotStack;
  final ValueChanged<bool> onDoNotStackChanged;
  final bool thisSideUp;
  final ValueChanged<bool> onThisSideUpChanged;
  final TextEditingController specialHandlingInstructionsController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Special Handling',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Fragile'),
                  value: fragile,
                  onChanged: isEditing ? onFragileChanged : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Do Not Stack'),
                  value: doNotStack,
                  onChanged: isEditing ? onDoNotStackChanged : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('This Side Up'),
                  value: thisSideUp,
                  onChanged: isEditing ? onThisSideUpChanged : null,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: specialHandlingInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Special Handling Instructions',
              hintText: 'Additional handling requirements',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            enabled: isEditing,
            maxLength: 1000,
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
          ),
        ],
      ),
    );
  }
}
