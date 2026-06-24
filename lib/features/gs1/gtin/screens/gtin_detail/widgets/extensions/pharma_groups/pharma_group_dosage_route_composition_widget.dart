import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/dosage_route_composition_card_content.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharma_groups/pharma_group_dosage_route_ingredient_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

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
  })
  onChanged;

  @override
  State<DosageRouteCompositionGroupWidget> createState() =>
      _DosageRouteCompositionGroupWidgetState();
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
  List<DosageRouteIngredientRow> _activeIngredientRows = [];

  @override
  void initState() {
    super.initState();
    _dosageFormController = TextEditingController(
      text: widget.initialDosageForm,
    );
    _strengthController = TextEditingController(text: widget.initialStrength);
    _strengthUnitController = TextEditingController(
      text: widget.initialStrengthUnit,
    );
    _routeOfAdministrationController = TextEditingController(
      text: widget.initialRouteOfAdministration,
    );
    _inactiveIngredientsController = TextEditingController(
      text: widget.initialInactiveIngredients,
    );

    _activeIngredientRows = widget.initialActiveIngredients
        .map((e) => DosageRouteIngredientRow(initial: e, onChanged: _emitChange))
        .toList();

    _dosageFormController.addListener(_emitChange);
    _strengthController.addListener(_emitChange);
    _strengthUnitController.addListener(_emitChange);
    _routeOfAdministrationController.addListener(_emitChange);
    _inactiveIngredientsController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant DosageRouteCompositionGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDosageForm == oldWidget.initialDosageForm &&
        widget.initialStrength == oldWidget.initialStrength &&
        widget.initialStrengthUnit == oldWidget.initialStrengthUnit &&
        widget.initialRouteOfAdministration ==
            oldWidget.initialRouteOfAdministration &&
        widget.initialInactiveIngredients ==
            oldWidget.initialInactiveIngredients &&
        identical(
          widget.initialActiveIngredients,
          oldWidget.initialActiveIngredients,
        )) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      if (widget.initialRouteOfAdministration !=
              oldWidget.initialRouteOfAdministration &&
          widget.initialRouteOfAdministration !=
              _routeOfAdministrationController.text) {
        _routeOfAdministrationController.text =
            widget.initialRouteOfAdministration;
      }
      if (widget.initialInactiveIngredients !=
              oldWidget.initialInactiveIngredients &&
          widget.initialInactiveIngredients !=
              _inactiveIngredientsController.text) {
        _inactiveIngredientsController.text = widget.initialInactiveIngredients;
      }
      if (!identical(
        widget.initialActiveIngredients,
        oldWidget.initialActiveIngredients,
      )) {
        for (final row in _activeIngredientRows) {
          row.dispose();
        }
        setState(() {
          _activeIngredientRows = widget.initialActiveIngredients
              .map((e) => DosageRouteIngredientRow(initial: e, onChanged: _emitChange))
              .toList();
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: EdgeInsets.zero,
      child: DosageRouteCompositionCardContent(
        isEditing: widget.isEditing,
        dosageFormController: _dosageFormController,
        strengthController: _strengthController,
        strengthUnitController: _strengthUnitController,
        routeOfAdministrationController: _routeOfAdministrationController,
        inactiveIngredientsController: _inactiveIngredientsController,
        dosageFormOptions: _dosageFormOptions,
        routeOptions: _routeOptions,
        activeIngredientRows: _activeIngredientRows,
        onAddIngredientRow: () {
          setState(() {
            _activeIngredientRows.add(
              DosageRouteIngredientRow(onChanged: _emitChange),
            );
          });
          _emitChange();
        },
        onRemoveIngredientRow: (index) {
          setState(() {
            final removed = _activeIngredientRows.removeAt(index);
            removed.dispose();
          });
          _emitChange();
        },
      ),
    );
    return Gs1GroupCard(
      title: 'Dosage, route & composition',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 3,
      child: content,
    );
  }
}
