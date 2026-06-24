import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

class SsccPharmaCarrierSection extends StatelessWidget {
  const SsccPharmaCarrierSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.carrierGdpQualificationNumberController,
    required this.carrierGdpQualificationExpiry,
    required this.onCarrierGdpQualificationExpiryTap,
    required this.vehicleQualificationNumberController,
    required this.vehicleLastQualificationDate,
    required this.onVehicleLastQualificationDateTap,
  });

  final Color outlineColor;
  final bool isEditing;
  final TextEditingController carrierGdpQualificationNumberController;
  final DateTime? carrierGdpQualificationExpiry;
  final VoidCallback? onCarrierGdpQualificationExpiryTap;
  final TextEditingController vehicleQualificationNumberController;
  final DateTime? vehicleLastQualificationDate;
  final VoidCallback? onVehicleLastQualificationDateTap;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Carrier/Transport Qualification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: carrierGdpQualificationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Carrier GDP Qualification Number',
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
                  label: 'Carrier GDP Qualification Expiry',
                  value: carrierGdpQualificationExpiry,
                  emptyValueLabel: 'Not set (optional)',
                  onTap: onCarrierGdpQualificationExpiryTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: vehicleQualificationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Qualification Number',
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
                  label: 'Vehicle Last Qualified',
                  value: vehicleLastQualificationDate,
                  emptyValueLabel: 'Not set (optional)',
                  onTap: onVehicleLastQualificationDateTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
