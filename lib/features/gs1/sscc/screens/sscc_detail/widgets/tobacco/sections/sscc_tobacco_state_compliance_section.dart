import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_tobacco_constants.dart';

class SsccTobaccoStateComplianceSection extends StatelessWidget {
  const SsccTobaccoStateComplianceSection({
    super.key,
    required this.isEditing,
    required this.pactActManifestNumberController,
    required this.stateTransitPermitNumberController,
    required this.stateTransitPermitState,
    required this.onStateTransitPermitStateChanged,
  });

  final bool isEditing;
  final TextEditingController pactActManifestNumberController;
  final TextEditingController stateTransitPermitNumberController;
  final String? stateTransitPermitState;
  final ValueChanged<String?> onStateTransitPermitStateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State/Regional Compliance (US)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pactActManifestNumberController,
          decoration: const InputDecoration(
            labelText: 'PACT Act Manifest Number',
            hintText: 'Prevent All Cigarette Trafficking manifest',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: stateTransitPermitNumberController,
                decoration: const InputDecoration(
                  labelText: 'State Transit Permit Number',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: stateTransitPermitState,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select'),
                  ),
                  ...ssccTobaccoUsStateOptions.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.key} - ${e.value}'),
                      )),
                ],
                onChanged: isEditing ? onStateTransitPermitStateChanged : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
