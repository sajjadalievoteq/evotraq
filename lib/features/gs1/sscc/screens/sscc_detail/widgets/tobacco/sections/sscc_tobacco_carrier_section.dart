import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SsccTobaccoCarrierSection extends StatelessWidget {
  const SsccTobaccoCarrierSection({
    super.key,
    required this.isEditing,
    required this.carrierLicenseNumberController,
    required this.carrierTobaccoPermitNumberController,
    required this.driverIdController,
    required this.vehicleRegistrationController,
  });

  final bool isEditing;
  final TextEditingController carrierLicenseNumberController;
  final TextEditingController carrierTobaccoPermitNumberController;
  final TextEditingController driverIdController;
  final TextEditingController vehicleRegistrationController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carrier Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: carrierLicenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Carrier License Number',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: carrierTobaccoPermitNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tobacco Permit Number',
                  hintText: 'Carrier tobacco transport permit',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: driverIdController,
                decoration: const InputDecoration(
                  labelText: 'Driver ID',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: vehicleRegistrationController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Registration',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
