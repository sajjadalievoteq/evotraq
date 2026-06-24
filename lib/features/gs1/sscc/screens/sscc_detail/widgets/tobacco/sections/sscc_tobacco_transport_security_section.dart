import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_tobacco_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

class SsccTobaccoTransportSecuritySection extends StatelessWidget {
  const SsccTobaccoTransportSecuritySection({
    super.key,
    required this.isEditing,
    required this.sealNumberController,
    required this.sealType,
    required this.onSealTypeChanged,
    required this.sealedByController,
    required this.sealedDate,
    required this.onSealedDateTap,
  });

  final bool isEditing;
  final TextEditingController sealNumberController;
  final String? sealType;
  final ValueChanged<String?> onSealTypeChanged;
  final TextEditingController sealedByController;
  final DateTime? sealedDate;
  final VoidCallback? onSealedDateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport Security',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: sealNumberController,
                decoration: const InputDecoration(
                  labelText: 'Seal Number',
                  hintText: 'Container seal ID',
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
                decoration: const InputDecoration(
                  labelText: 'Seal Type',
                  border: OutlineInputBorder(),
                ),
                value: sealType,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Seal Type'),
                  ),
                  ...ssccTobaccoSealTypeOptions.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )),
                ],
                onChanged: isEditing ? onSealTypeChanged : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: sealedByController,
                decoration: const InputDecoration(
                  labelText: 'Sealed By',
                  hintText: 'Person/organization who applied seal',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 255,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1DatePickerField(
                label: 'Sealed Date',
                value: sealedDate,
                emptyValueLabel: 'Not set (optional)',
                onTap: onSealedDateTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
