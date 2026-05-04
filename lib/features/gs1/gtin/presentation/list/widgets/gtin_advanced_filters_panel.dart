import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

class GtinAdvancedFiltersPanel extends StatelessWidget {
  const GtinAdvancedFiltersPanel({
    super.key,
    required this.productNameController,
    required this.gtinCodeController,
    required this.manufacturerController,
    required this.registrationDateFromController,
    required this.registrationDateToController,
    required this.selectedPackagingLevel,
    required this.onPackagingLevelChanged,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController productNameController;
  final TextEditingController gtinCodeController;
  final TextEditingController manufacturerController;
  final TextEditingController registrationDateFromController;
  final TextEditingController registrationDateToController;

  final String? selectedPackagingLevel;
  final ValueChanged<String?> onPackagingLevelChanged;

  final VoidCallback onPickFromDate;
  final VoidCallback onPickToDate;

  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    // This panel contains multiple form fields; isolate repaints to avoid
    // affecting list scroll performance when it's visible.
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
              GtinUiConstants.advancedFiltersHeader,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              GtinUiConstants.advancedFiltersNote,
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
                    controller: productNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: GtinUiConstants.labelProductNameField,
                      hintText: GtinUiConstants.hintProductNameExample,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: gtinCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: GtinUiConstants.labelGtinCodeField,
                      hintText: GtinUiConstants.hintGtinCodeExample,
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
                    key: ValueKey<String?>(selectedPackagingLevel),
                    initialValue: selectedPackagingLevel,
                    decoration: const InputDecoration(
                      labelText: GtinUiConstants.labelPackagingLevelField,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: GtinUiConstants.packagingLevelOptions
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: onPackagingLevelChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: manufacturerController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: GtinUiConstants.labelManufacturerField,
                      hintText: GtinUiConstants.hintManufacturerExample,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: registrationDateFromController,
                          decoration: InputDecoration(
                            labelText: GtinUiConstants.labelRegDateFrom,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          suffixIcon: CustomButtonWidget(
                            onTap: onPickFromDate,
                            icon: Icons.calendar_today,
                            iconOnly: true,
                            tooltip: GtinUiConstants.tooltipPickFromDate,
                            height: 40,
                          ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: registrationDateToController,
                          decoration: InputDecoration(
                            labelText: GtinUiConstants.labelRegDateTo,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          suffixIcon: CustomButtonWidget(
                            onTap: onPickToDate,
                            icon: Icons.calendar_today,
                            iconOnly: true,
                            tooltip: GtinUiConstants.tooltipPickToDate,
                            height: 40,
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    onTap: onApply,
                    title: GtinUiConstants.buttonApplyFilters,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomOutlinedButtonWidget(
                    title: GtinUiConstants.buttonClearAll,
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
                      GtinUiConstants.advancedFiltersSuccessBanner,
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

