import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class ControlledSubstanceGroupWidget extends StatefulWidget {
  const ControlledSubstanceGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialIsControlledSubstance,
    required this.initialDeaSchedule,
    required this.initialControlClass,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final bool initialIsControlledSubstance;
  final DeaSchedule initialDeaSchedule;
  final String initialControlClass;
  final bool showFieldSkeleton;
  final void Function({
    required bool isControlledSubstance,
    required DeaSchedule deaSchedule,
    required String controlClass,
  }) onChanged;

  @override
  State<ControlledSubstanceGroupWidget> createState() =>
      _ControlledSubstanceGroupWidgetState();
}

class _ControlledSubstanceGroupWidgetState
    extends State<ControlledSubstanceGroupWidget> {
  late bool _isControlledSubstance;
  late DeaSchedule _deaSchedule;
  late final TextEditingController _controlClassController;

  @override
  void initState() {
    super.initState();
    _isControlledSubstance = widget.initialIsControlledSubstance;
    _deaSchedule = widget.initialDeaSchedule;
    _controlClassController = TextEditingController(text: widget.initialControlClass);
    _controlClassController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant ControlledSubstanceGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsControlledSubstance == oldWidget.initialIsControlledSubstance &&
        widget.initialDeaSchedule == oldWidget.initialDeaSchedule &&
        widget.initialControlClass == oldWidget.initialControlClass) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isControlledSubstance = widget.initialIsControlledSubstance;
        _deaSchedule = widget.initialDeaSchedule;
      });
      if (widget.initialControlClass != oldWidget.initialControlClass &&
          widget.initialControlClass != _controlClassController.text) {
        _controlClassController.text = widget.initialControlClass;
      }
    });
  }

  @override
  void dispose() {
    _controlClassController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      isControlledSubstance: _isControlledSubstance,
      deaSchedule: _deaSchedule,
      controlClass: _controlClassController.text,
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
            'Controlled substance',
            padding: EdgeInsets.only(bottom: 12),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Is Controlled Substance'),
            value: _isControlledSubstance,
            onChanged: widget.isEditing
                ? (value) {
                    setState(() {
                      _isControlledSubstance = value;
                      if (!value) {
                        _deaSchedule = DeaSchedule.none;
                      }
                    });
                    _emitChange();
                  }
                : null,
          ),
          if (_isControlledSubstance)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownButtonFormField<DeaSchedule>(
                value: _deaSchedule,
                decoration: const InputDecoration(
                  labelText: 'DEA Schedule',
                  border: OutlineInputBorder(),
                ),
                items: DeaSchedule.values
                    .map(
                      (schedule) => DropdownMenuItem(
                        value: schedule,
                        child: Text(schedule.displayName),
                      ),
                    )
                    .toList(),
                onChanged: widget.isEditing
                    ? (value) {
                        setState(() {
                          _deaSchedule = value ?? DeaSchedule.none;
                        });
                        _emitChange();
                      }
                    : null,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GtinValidatedField(
              controller: _controlClassController,
              fieldName: 'controlClass',
              label: 'Control class',
              helperText: 'Regional control classification (optional)',
              maxLength: 80,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              readOnly: !widget.isEditing,
              validator: PharmaFieldValidators.validateControlClass,
            ),
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
                'Controlled substance',
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
