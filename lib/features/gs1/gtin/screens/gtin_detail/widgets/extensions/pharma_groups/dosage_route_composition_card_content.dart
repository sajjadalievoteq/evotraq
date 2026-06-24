import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_form_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_dosage_route_ingredient_row.dart';

class DosageRouteCompositionCardContent extends StatelessWidget {
  const DosageRouteCompositionCardContent({
    super.key,
    required this.isEditing,
    required this.dosageFormController,
    required this.strengthController,
    required this.strengthUnitController,
    required this.routeOfAdministrationController,
    required this.inactiveIngredientsController,
    required this.dosageFormOptions,
    required this.routeOptions,
    required this.activeIngredientRows,
    required this.onAddIngredientRow,
    required this.onRemoveIngredientRow,
  });

  final bool isEditing;
  final TextEditingController dosageFormController;
  final TextEditingController strengthController;
  final TextEditingController strengthUnitController;
  final TextEditingController routeOfAdministrationController;
  final TextEditingController inactiveIngredientsController;
  final List<String> dosageFormOptions;
  final List<String> routeOptions;
  final List<DosageRouteIngredientRow> activeIngredientRows;
  final VoidCallback onAddIngredientRow;
  final ValueChanged<int> onRemoveIngredientRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: dosageFormController.text.isEmpty
              ? null
              : dosageFormOptions.contains(dosageFormController.text)
              ? dosageFormController.text
              : null,
          decoration: const InputDecoration(
            labelText: 'Dosage Form',
            border: OutlineInputBorder(),
          ),
          items: dosageFormOptions
              .map((form) => DropdownMenuItem(value: form, child: Text(form)))
              .toList(),
          onChanged: isEditing
              ? (value) {
                  dosageFormController.text = value ?? '';
                }
              : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PharmaGroupFormField(
                controller: strengthController,
                fieldName: 'strength',
                label: 'Strength',
                isEditing: isEditing,
                helperText: 'e.g., 500',
                maxLength: 100,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PharmaGroupFormField(
                controller: strengthUnitController,
                fieldName: 'strengthUnit',
                label: 'Unit',
                isEditing: isEditing,
                helperText: 'e.g., mg',
                maxLength: 20,
              ),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          value: routeOfAdministrationController.text.isEmpty
              ? null
              : routeOptions.contains(routeOfAdministrationController.text)
              ? routeOfAdministrationController.text
              : null,
          decoration: const InputDecoration(
            labelText: 'Route of Administration',
            border: OutlineInputBorder(),
          ),
          items: routeOptions
              .map(
                (route) => DropdownMenuItem(value: route, child: Text(route)),
              )
              .toList(),
          onChanged: isEditing
              ? (value) {
                  routeOfAdministrationController.text = value ?? '';
                }
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          'Active substances (repeatable). Rows with an empty name are omitted on save.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...List<Widget>.generate(activeIngredientRows.length, (index) {
          final row = activeIngredientRows[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PharmaGroupFormField(
                          controller: row.name,
                          fieldName: 'activeIngredientName$index',
                          label: 'Active substance name',
                          isEditing: isEditing,
                          maxLength: 200,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove row',
                        onPressed: isEditing
                            ? () => onRemoveIngredientRow(index)
                            : null,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: PharmaGroupFormField(
                          controller: row.amount,
                          fieldName: 'activeIngredientAmount$index',
                          label: 'Amount',
                          isEditing: isEditing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          maxLength: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PharmaGroupFormField(
                          controller: row.unit,
                          fieldName: 'activeIngredientUnit$index',
                          label: 'Unit',
                          isEditing: isEditing,
                          maxLength: 24,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: PharmaGroupFormField(
                          controller: row.substanceRoleCode,
                          fieldName: 'activeIngredientRole$index',
                          label: 'Substance role code',
                          isEditing: isEditing,
                          helperText: 'Default ACTIVE',
                          maxLength: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PharmaGroupFormField(
                          controller: row.sequence,
                          fieldName: 'activeIngredientSequence$index',
                          label: 'Sequence',
                          isEditing: isEditing,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                        ),
                      ),
                    ],
                  ),
                  PharmaGroupFormField(
                    controller: row.basisOfStrength,
                    fieldName: 'activeIngredientBasis$index',
                    label: 'Basis of strength',
                    isEditing: isEditing,
                    maxLength: 120,
                  ),
                ],
              ),
            ),
          );
        }),
        if (isEditing)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddIngredientRow,
              icon: const Icon(Icons.add),
              label: const Text('Add active ingredient row'),
            ),
          ),
        PharmaGroupFormField(
          controller: inactiveIngredientsController,
          fieldName: 'inactiveIngredients',
          label: 'Inactive ingredients',
          isEditing: isEditing,
          helperText: 'Excipients / non-active components (free text)',
          maxLines: 4,
          maxLength: 2000,
        ),
      ],
    );
  }
}
