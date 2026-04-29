import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/models/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class WarningsPrecautionsGroupWidget extends StatefulWidget {
  const WarningsPrecautionsGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialBlackBoxWarning,
    required this.initialBlackBoxWarningText,
    required this.initialPregnancyCategory,
    required this.initialContraindications,
    required this.initialDrugInteractions,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final bool initialBlackBoxWarning;
  final String initialBlackBoxWarningText;
  final PregnancyCategory initialPregnancyCategory;
  final String initialContraindications;
  final String initialDrugInteractions;
  final bool showFieldSkeleton;
  final void Function({
    required bool blackBoxWarning,
    required String blackBoxWarningText,
    required PregnancyCategory pregnancyCategory,
    required String contraindications,
    required String drugInteractions,
  }) onChanged;

  @override
  State<WarningsPrecautionsGroupWidget> createState() =>
      _WarningsPrecautionsGroupWidgetState();
}

class _WarningsPrecautionsGroupWidgetState
    extends State<WarningsPrecautionsGroupWidget> {
  late bool _blackBoxWarning;
  late PregnancyCategory _pregnancyCategory;
  late final TextEditingController _blackBoxWarningTextController;
  late final TextEditingController _contraindicationsController;
  late final TextEditingController _drugInteractionsController;

  @override
  void initState() {
    super.initState();
    _blackBoxWarning = widget.initialBlackBoxWarning;
    _pregnancyCategory = widget.initialPregnancyCategory;
    _blackBoxWarningTextController =
        TextEditingController(text: widget.initialBlackBoxWarningText);
    _contraindicationsController =
        TextEditingController(text: widget.initialContraindications);
    _drugInteractionsController =
        TextEditingController(text: widget.initialDrugInteractions);
    _blackBoxWarningTextController.addListener(_emitChange);
    _contraindicationsController.addListener(_emitChange);
    _drugInteractionsController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant WarningsPrecautionsGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _blackBoxWarning = widget.initialBlackBoxWarning;
    _pregnancyCategory = widget.initialPregnancyCategory;
    if (widget.initialBlackBoxWarningText != oldWidget.initialBlackBoxWarningText &&
        widget.initialBlackBoxWarningText != _blackBoxWarningTextController.text) {
      _blackBoxWarningTextController.text = widget.initialBlackBoxWarningText;
    }
    if (widget.initialContraindications != oldWidget.initialContraindications &&
        widget.initialContraindications != _contraindicationsController.text) {
      _contraindicationsController.text = widget.initialContraindications;
    }
    if (widget.initialDrugInteractions != oldWidget.initialDrugInteractions &&
        widget.initialDrugInteractions != _drugInteractionsController.text) {
      _drugInteractionsController.text = widget.initialDrugInteractions;
    }
  }

  @override
  void dispose() {
    _blackBoxWarningTextController.dispose();
    _contraindicationsController.dispose();
    _drugInteractionsController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      blackBoxWarning: _blackBoxWarning,
      blackBoxWarningText: _blackBoxWarningTextController.text,
      pregnancyCategory: _pregnancyCategory,
      contraindications: _contraindicationsController.text,
      drugInteractions: _drugInteractionsController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'Warnings & precautions',
            padding: EdgeInsets.only(bottom: 12),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Black Box Warning'),
            subtitle: const Text('FDA\'s most serious warning'),
            value: _blackBoxWarning,
            activeThumbColor: Colors.red,
            onChanged: widget.isEditing
                ? (value) {
                    setState(() => _blackBoxWarning = value);
                    _emitChange();
                  }
                : null,
          ),
          if (_blackBoxWarning)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GtinValidatedField(
                controller: _blackBoxWarningTextController,
                fieldName: 'blackBoxWarningText',
                label: 'Black Box Warning Text',
                maxLines: 3,
                maxLength: 1000,
                inputFormatters:  [LengthLimitingTextInputFormatter(1000)],
                readOnly: !widget.isEditing,
                validator: PharmaFieldValidators.validateBlackBoxWarningText,
              ),
            ),
          DropdownButtonFormField<PregnancyCategory>(
            value: _pregnancyCategory,
            decoration: const InputDecoration(
              labelText: 'Pregnancy Category',
              border: OutlineInputBorder(),
            ),
            items: PregnancyCategory.values
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.displayName)))
                .toList(),
            onChanged: widget.isEditing
                ? (value) {
                    setState(() {
                      _pregnancyCategory = value ?? PregnancyCategory.notClassified;
                    });
                    _emitChange();
                  }
                : null,
          ),
          const SizedBox(height: 8),
          GtinValidatedField(
            controller: _contraindicationsController,
            fieldName: 'contraindications',
            label: 'Contraindications',
            maxLines: 2,
            maxLength: 1000,
            inputFormatters:  [LengthLimitingTextInputFormatter(1000)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateContraindications,
          ),
          GtinValidatedField(
            controller: _drugInteractionsController,
            fieldName: 'drugInteractions',
            label: 'Drug Interactions',
            maxLines: 2,
            maxLength: 1000,
            inputFormatters:  [LengthLimitingTextInputFormatter(1000)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateDrugInteractions,
          ),
        ],
      ),
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
                'Warnings & precautions',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
