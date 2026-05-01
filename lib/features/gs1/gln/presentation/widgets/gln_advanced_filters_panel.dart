import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

class GlnAdvancedFiltersPanel extends StatelessWidget {
  const GlnAdvancedFiltersPanel({
    super.key,
    required this.locationNameController,
    required this.glnCodeController,
    required this.addressController,
    required this.licenseNumberController,
    required this.contactEmailController,
    required this.contactNameController,
    required this.selectedLocationType,
    required this.selectedStatus,
    required this.sortBy,
    required this.onLocationTypeChanged,
    required this.onStatusChanged,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController locationNameController;
  final TextEditingController glnCodeController;
  final TextEditingController addressController;
  final TextEditingController licenseNumberController;
  final TextEditingController contactEmailController;
  final TextEditingController contactNameController;

  final String? selectedLocationType;
  final String? selectedStatus;
  final String sortBy;

  final ValueChanged<String?> onLocationTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSortByChanged;

  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(Constants.spacing),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Filters (Database Filters)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Note: These filters are applied at database level for precise results',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                      hintText: 'e.g., Main Warehouse, Central Pharmacy',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: glnCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'GLN Code',
                      hintText: 'e.g., 1234567890123',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedLocationType,
                    decoration: const InputDecoration(
                      labelText: 'Location Type',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: GlnUiConstants.locationTypeOptions.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: onLocationTypeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: GlnUiConstants.statusOptions.map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status));
                    }).toList(),
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addressController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Street, city, state, country',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: licenseNumberController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'License Number',
                      hintText: 'Regulatory license number',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: contactNameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort results by',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: GlnUiConstants.sortFieldLabels.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: onSortByChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    onTap: onApply,
                    title: 'Apply Filters',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomOutlinedButtonWidget(
                    title: 'Clear All',
                    onTap: onClearAll,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Database-level filtering is now active! These filters are applied directly at the database for optimal performance with large datasets.',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
