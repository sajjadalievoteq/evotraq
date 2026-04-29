import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/models/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';

class DosageRouteCompositionGroupWidget extends StatefulWidget {
  const DosageRouteCompositionGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialDosageForm,
    required this.initialStrength,
    required this.initialStrengthUnit,
    required this.initialRouteOfAdministration,
    required this.initialActiveIngredients,
    required this.initialInactiveIngredients,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialDosageForm;
  final String initialStrength;
  final String initialStrengthUnit;
  final String initialRouteOfAdministration;
  final List<ActiveIngredient> initialActiveIngredients;
  final String initialInactiveIngredients;
  final bool showFieldSkeleton;
  final void Function({
    required String dosageForm,
    required String strength,
    required String strengthUnit,
    required String routeOfAdministration,
    required List<ActiveIngredient> activeIngredients,
    required String inactiveIngredients,
  }) onChanged;

  @override
  State<DosageRouteCompositionGroupWidget> createState() =>
      _DosageRouteCompositionGroupWidgetState();
}

class _IngredientRow {
  _IngredientRow({ActiveIngredient? initial, this.onChanged}) {
    if (initial != null) {
      name.text = initial.name;
      amount.text = initial.amount?.toString() ?? '';
      unit.text = initial.unit ?? '';
      substanceRoleCode.text =
          initial.substanceRoleCode.isEmpty ? 'ACTIVE' : initial.substanceRoleCode;
      sequence.text = initial.sequence.toString();
      basisOfStrength.text = initial.basisOfStrength ?? '';
    }
    name.addListener(_notifyChange);
    amount.addListener(_notifyChange);
    unit.addListener(_notifyChange);
    substanceRoleCode.addListener(_notifyChange);
    sequence.addListener(_notifyChange);
    basisOfStrength.addListener(_notifyChange);
  }

  final VoidCallback? onChanged;

  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController substanceRoleCode = TextEditingController(text: 'ACTIVE');
  final TextEditingController sequence = TextEditingController(text: '0');
  final TextEditingController basisOfStrength = TextEditingController();

  void _notifyChange() => onChanged?.call();

  void dispose() {
    name.dispose();
    amount.dispose();
    unit.dispose();
    substanceRoleCode.dispose();
    sequence.dispose();
    basisOfStrength.dispose();
  }

  ActiveIngredient toIngredient() {
    final seq = int.tryParse(sequence.text.trim());
    return ActiveIngredient(
      name: name.text.trim(),
      amount: amount.text.trim().isEmpty ? null : double.tryParse(amount.text.trim()),
      unit: unit.text.trim().isEmpty ? null : unit.text.trim(),
      substanceRoleCode:
          substanceRoleCode.text.trim().isEmpty ? 'ACTIVE' : substanceRoleCode.text.trim(),
      sequence: seq ?? 0,
      basisOfStrength:
          basisOfStrength.text.trim().isEmpty ? null : basisOfStrength.text.trim(),
    );
  }
}

class _DosageRouteCompositionGroupWidgetState
    extends State<DosageRouteCompositionGroupWidget> {
  static const List<String> _dosageFormOptions = [
    'Tablet',
    'Capsule',
    'Injection',
    'Solution',
    'Suspension',
    'Syrup',
    'Cream',
    'Ointment',
    'Gel',
    'Patch',
    'Suppository',
    'Inhaler',
    'Spray',
    'Drops',
    'Powder',
    'Other',
  ];

  static const List<String> _routeOptions = [
    'Oral',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous (SC)',
    'Topical',
    'Transdermal',
    'Inhalation',
    'Rectal',
    'Vaginal',
    'Ophthalmic',
    'Otic',
    'Nasal',
    'Sublingual',
    'Buccal',
    'Intradermal',
    'Other',
  ];

  late final TextEditingController _dosageFormController;
  late final TextEditingController _strengthController;
  late final TextEditingController _strengthUnitController;
  late final TextEditingController _routeOfAdministrationController;
  late final TextEditingController _inactiveIngredientsController;
  List<_IngredientRow> _activeIngredientRows = [];

  @override
  void initState() {
    super.initState();
    _dosageFormController = TextEditingController(text: widget.initialDosageForm);
    _strengthController = TextEditingController(text: widget.initialStrength);
    _strengthUnitController = TextEditingController(text: widget.initialStrengthUnit);
    _routeOfAdministrationController =
        TextEditingController(text: widget.initialRouteOfAdministration);
    _inactiveIngredientsController =
        TextEditingController(text: widget.initialInactiveIngredients);

    _activeIngredientRows =
        widget.initialActiveIngredients.map((e) => _IngredientRow(initial: e, onChanged: _emitChange)).toList();

    _dosageFormController.addListener(_emitChange);
    _strengthController.addListener(_emitChange);
    _strengthUnitController.addListener(_emitChange);
    _routeOfAdministrationController.addListener(_emitChange);
    _inactiveIngredientsController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant DosageRouteCompositionGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDosageForm != oldWidget.initialDosageForm &&
        widget.initialDosageForm != _dosageFormController.text) {
      _dosageFormController.text = widget.initialDosageForm;
    }
    if (widget.initialStrength != oldWidget.initialStrength &&
        widget.initialStrength != _strengthController.text) {
      _strengthController.text = widget.initialStrength;
    }
    if (widget.initialStrengthUnit != oldWidget.initialStrengthUnit &&
        widget.initialStrengthUnit != _strengthUnitController.text) {
      _strengthUnitController.text = widget.initialStrengthUnit;
    }
    if (widget.initialRouteOfAdministration != oldWidget.initialRouteOfAdministration &&
        widget.initialRouteOfAdministration != _routeOfAdministrationController.text) {
      _routeOfAdministrationController.text = widget.initialRouteOfAdministration;
    }
    if (widget.initialInactiveIngredients != oldWidget.initialInactiveIngredients &&
        widget.initialInactiveIngredients != _inactiveIngredientsController.text) {
      _inactiveIngredientsController.text = widget.initialInactiveIngredients;
    }
    if (!identical(widget.initialActiveIngredients, oldWidget.initialActiveIngredients)) {
      for (final row in _activeIngredientRows) {
        row.dispose();
      }
      _activeIngredientRows = widget.initialActiveIngredients
          .map((e) => _IngredientRow(initial: e, onChanged: _emitChange))
          .toList();
    }
  }

  @override
  void dispose() {
    _dosageFormController.dispose();
    _strengthController.dispose();
    _strengthUnitController.dispose();
    _routeOfAdministrationController.dispose();
    _inactiveIngredientsController.dispose();
    for (final row in _activeIngredientRows) {
      row.dispose();
    }
    super.dispose();
  }

  List<ActiveIngredient> _activeIngredientsFromRows() {
    return _activeIngredientRows
        .map((r) => r.toIngredient())
        .where((i) => i.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  void _emitChange() {
    widget.onChanged(
      dosageForm: _dosageFormController.text,
      strength: _strengthController.text,
      strengthUnit: _strengthUnitController.text,
      routeOfAdministration: _routeOfAdministrationController.text,
      activeIngredients: _activeIngredientsFromRows(),
      inactiveIngredients: _inactiveIngredientsController.text,
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String fieldName,
    String label, {
    String? helperText,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GtinValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
        readOnly: !widget.isEditing,
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          'Dosage, route & composition',
          padding: EdgeInsets.only(bottom: 12),
        ),
        DropdownButtonFormField<String>(
          value: _dosageFormController.text.isEmpty
              ? null
              : _dosageFormOptions.contains(_dosageFormController.text)
                  ? _dosageFormController.text
                  : null,
          decoration: const InputDecoration(
            labelText: 'Dosage Form',
            border: OutlineInputBorder(),
          ),
          items: _dosageFormOptions
              .map((form) => DropdownMenuItem(value: form, child: Text(form)))
              .toList(),
          onChanged: widget.isEditing
              ? (value) {
                  _dosageFormController.text = value ?? '';
                }
              : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildField(
                _strengthController,
                'strength',
                'Strength',
                helperText: 'e.g., 500',
                maxLength: 100,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildField(
                _strengthUnitController,
                'strengthUnit',
                'Unit',
                helperText: 'e.g., mg',
                maxLength: 20,
              ),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          value: _routeOfAdministrationController.text.isEmpty
              ? null
              : _routeOptions.contains(_routeOfAdministrationController.text)
                  ? _routeOfAdministrationController.text
                  : null,
          decoration: const InputDecoration(
            labelText: 'Route of Administration',
            border: OutlineInputBorder(),
          ),
          items: _routeOptions
              .map((route) => DropdownMenuItem(value: route, child: Text(route)))
              .toList(),
          onChanged: widget.isEditing
              ? (value) {
                  _routeOfAdministrationController.text = value ?? '';
                }
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          'Active substances (repeatable). Rows with an empty name are omitted on save.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...List<Widget>.generate(_activeIngredientRows.length, (index) {
          final row = _activeIngredientRows[index];
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
                        child: _buildField(
                          row.name,
                          'activeIngredientName$index',
                          'Active substance name',
                          maxLength: 200,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove row',
                        onPressed: widget.isEditing
                            ? () {
                                setState(() {
                                  final removed = _activeIngredientRows.removeAt(index);
                                  removed.dispose();
                                });
                                _emitChange();
                              }
                            : null,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          row.amount,
                          'activeIngredientAmount$index',
                          'Amount',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          maxLength: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildField(
                          row.unit,
                          'activeIngredientUnit$index',
                          'Unit',
                          maxLength: 24,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          row.substanceRoleCode,
                          'activeIngredientRole$index',
                          'Substance role code',
                          helperText: 'Default ACTIVE',
                          maxLength: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildField(
                          row.sequence,
                          'activeIngredientSequence$index',
                          'Sequence',
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                        ),
                      ),
                    ],
                  ),
                  _buildField(
                    row.basisOfStrength,
                    'activeIngredientBasis$index',
                    'Basis of strength',
                    maxLength: 120,
                  ),
                ],
              ),
            ),
          );
        }),
        if (widget.isEditing)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _activeIngredientRows.add(_IngredientRow(onChanged: _emitChange));
                });
                _emitChange();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add active ingredient row'),
            ),
          ),
        _buildField(
          _inactiveIngredientsController,
          'inactiveIngredients',
          'Inactive ingredients',
          helperText: 'Excipients / non-active components (free text)',
          maxLines: 4,
          maxLength: 2000,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: _buildCardContent(context),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: widget.showFieldSkeleton,
        child: content,
        skeletonBuilder: (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel(
                'Dosage, route & composition',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
              SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
