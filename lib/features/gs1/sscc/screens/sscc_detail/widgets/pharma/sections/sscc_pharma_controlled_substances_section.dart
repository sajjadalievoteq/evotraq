import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_pharma_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaControlledSubstancesSection extends StatelessWidget {
  const SsccPharmaControlledSubstancesSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.containsControlledSubstance,
    required this.onContainsControlledSubstanceChanged,
    required this.deaSchedule,
    required this.onDeaScheduleChanged,
    required this.deaOrderFormNumberController,
    required this.incbAuthorizationNumberController,
    required this.narcoticTransitPermitController,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool containsControlledSubstance;
  final ValueChanged<bool> onContainsControlledSubstanceChanged;
  final String? deaSchedule;
  final ValueChanged<String?> onDeaScheduleChanged;
  final TextEditingController deaOrderFormNumberController;
  final TextEditingController incbAuthorizationNumberController;
  final TextEditingController narcoticTransitPermitController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Controlled Substances (DEA/INCB)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Contains Controlled Substance'),
            subtitle:
                const Text('Shipment contains DEA/INCB scheduled substances'),
            value: containsControlledSubstance,
            onChanged:
                isEditing ? onContainsControlledSubstanceChanged : null,
          ),
          if (containsControlledSubstance) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'DEA Schedule',
                border: OutlineInputBorder(),
              ),
              value: deaSchedule,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select Schedule'),
                ),
                ...ssccDeaScheduleOptions.map((schedule) => DropdownMenuItem(
                      value: schedule,
                      child: Text(schedule),
                    )),
              ],
              onChanged: isEditing ? onDeaScheduleChanged : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: deaOrderFormNumberController,
              decoration: const InputDecoration(
                labelText: 'DEA Order Form Number (DEA-222)',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: incbAuthorizationNumberController,
              decoration: const InputDecoration(
                labelText: 'INCB Authorization Number',
                hintText: 'International Narcotics Control Board',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              maxLength: 100,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: narcoticTransitPermitController,
              decoration: const InputDecoration(
                labelText: 'Narcotic Transit Permit',
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
