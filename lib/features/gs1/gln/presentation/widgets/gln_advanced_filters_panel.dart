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
    final locationTypeValue =
        selectedLocationType ?? GlnUiConstants.filterAll;
    final statusValue = selectedStatus ?? GlnUiConstants.filterAll;

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
            Text(
              GlnUiConstants.advancedFiltersHeader,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              GlnUiConstants.advancedFiltersNote,
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
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelLocationNameField,
                      hintText: GlnUiConstants.hintLocationNameExample,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: glnCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelGlnCode,
                      hintText: GlnUiConstants.hintGlnCodeExample,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    key: ValueKey(locationTypeValue),
                    initialValue: locationTypeValue,
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelLocationType,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    key: ValueKey(statusValue),
                    initialValue: statusValue,
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelStatus,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelAddress,
                      hintText: GlnUiConstants.hintAddress,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: licenseNumberController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelLicenseNumberField,
                      hintText: GlnUiConstants.hintLicenseNumber,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelContactEmail,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: contactNameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: GlnUiConstants.labelContactNameField,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(sortBy),
              initialValue: sortBy,
              decoration: InputDecoration(
                labelText: GlnUiConstants.labelSortResultsBy,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    title: GlnUiConstants.buttonApplyFilters,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomOutlinedButtonWidget(
                    title: GlnUiConstants.buttonClearAll,
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
                      GlnUiConstants.advancedFiltersSuccessBanner,
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
