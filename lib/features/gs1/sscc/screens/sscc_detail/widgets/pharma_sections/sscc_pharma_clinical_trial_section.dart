import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaClinicalTrialSection extends StatelessWidget {
  const SsccPharmaClinicalTrialSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.clinicalTrialShipment,
    required this.onClinicalTrialShipmentChanged,
    required this.clinicalTrialProtocolNumberController,
    required this.irbApprovalNumberController,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool clinicalTrialShipment;
  final ValueChanged<bool> onClinicalTrialShipmentChanged;
  final TextEditingController clinicalTrialProtocolNumberController;
  final TextEditingController irbApprovalNumberController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Clinical Trial Shipments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Clinical Trial Shipment'),
            subtitle: const Text('Shipment for clinical trial'),
            value: clinicalTrialShipment,
            onChanged: isEditing ? onClinicalTrialShipmentChanged : null,
          ),
          if (clinicalTrialShipment) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: clinicalTrialProtocolNumberController,
              decoration: const InputDecoration(
                labelText: 'Clinical Trial Protocol Number',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: irbApprovalNumberController,
              decoration: const InputDecoration(
                labelText: 'IRB Approval Number',
                hintText: 'Institutional Review Board approval',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
          ],
        ],
      ),
    );
  }
}
