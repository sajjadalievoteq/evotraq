import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_pharma_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaHazmatSection extends StatelessWidget {
  const SsccPharmaHazmatSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.hazmatClass,
    required this.onHazmatClassChanged,
    required this.hazmatUnNumberController,
    required this.hazmatPackingGroup,
    required this.onHazmatPackingGroupChanged,
    required this.hazmatSpecialProvisionsController,
  });

  final Color outlineColor;
  final bool isEditing;
  final String? hazmatClass;
  final ValueChanged<String?> onHazmatClassChanged;
  final TextEditingController hazmatUnNumberController;
  final String? hazmatPackingGroup;
  final ValueChanged<String?> onHazmatPackingGroupChanged;
  final TextEditingController hazmatSpecialProvisionsController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Hazardous Materials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'HAZMAT Class',
                  border: OutlineInputBorder(),
                ),
                value: hazmatClass,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Class'),
                  ),
                  ...ssccHazmatClassOptions.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.key} - ${e.value}'),
                      )),
                ],
                onChanged: isEditing ? onHazmatClassChanged : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hazmatUnNumberController,
                decoration: const InputDecoration(
                  labelText: 'UN Number',
                  hintText: 'e.g., UN1234',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 10,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Packing Group',
                  border: OutlineInputBorder(),
                ),
                value: hazmatPackingGroup,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Group'),
                  ),
                  ...ssccHazmatPackingGroupOptions.map((group) => DropdownMenuItem(
                        value: group,
                        child: Text(
                          '$group - ${group == 'I' ? 'High Danger' : group == 'II' ? 'Medium Danger' : 'Low Danger'}',
                        ),
                      )),
                ],
                onChanged: isEditing ? onHazmatPackingGroupChanged : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hazmatSpecialProvisionsController,
                decoration: const InputDecoration(
                  labelText: 'Special Provisions',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 500,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
