import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

class SsccPharmaGdpSection extends StatelessWidget {
  const SsccPharmaGdpSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.gdpCompliant,
    required this.onGdpCompliantChanged,
    required this.gdpCertificateNumberController,
    required this.gdpCertificateExpiry,
    required this.onGdpCertificateExpiryTap,
    required this.gdpIssuingAuthorityController,
    required this.whoPqsRequired,
    required this.onWhoPqsRequiredChanged,
    required this.whoPqsEquipmentCodeController,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool gdpCompliant;
  final ValueChanged<bool> onGdpCompliantChanged;
  final TextEditingController gdpCertificateNumberController;
  final DateTime? gdpCertificateExpiry;
  final VoidCallback? onGdpCertificateExpiryTap;
  final TextEditingController gdpIssuingAuthorityController;
  final bool whoPqsRequired;
  final ValueChanged<bool> onWhoPqsRequiredChanged;
  final TextEditingController whoPqsEquipmentCodeController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'GDP (Good Distribution Practice) Compliance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('GDP Compliant'),
            subtitle: const Text('Shipment meets GDP requirements'),
            value: gdpCompliant,
            onChanged: isEditing ? onGdpCompliantChanged : null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: gdpCertificateNumberController,
                  decoration: const InputDecoration(
                    labelText: 'GDP Certificate Number',
                    border: OutlineInputBorder(),
                  ),
                  enabled: isEditing,
                  maxLength: 100,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Gs1DatePickerField(
                  label: 'GDP Certificate Expiry',
                  value: gdpCertificateExpiry,
                  emptyValueLabel: 'Not set (optional)',
                  onTap: onGdpCertificateExpiryTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: gdpIssuingAuthorityController,
            decoration: const InputDecoration(
              labelText: 'Issuing Authority',
              hintText: 'e.g., MHRA, EMA, FDA',
              border: OutlineInputBorder(),
            ),
            enabled: isEditing,
            maxLength: 255,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('WHO PQS Required'),
            subtitle: const Text('Prequalification Standard equipment required'),
            value: whoPqsRequired,
            onChanged: isEditing ? onWhoPqsRequiredChanged : null,
          ),
          if (whoPqsRequired) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: whoPqsEquipmentCodeController,
              decoration: const InputDecoration(
                labelText: 'WHO PQS Equipment Code',
                hintText: 'PQS equipment identifier',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              maxLength: 50,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
          ],
        ],
      ),
    );
  }
}
