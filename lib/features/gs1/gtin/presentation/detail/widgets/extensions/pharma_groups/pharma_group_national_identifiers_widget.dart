import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class NationalIdentifiersGroupWidget extends StatefulWidget {
  const NationalIdentifiersGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialNhmnGermanyPzn,
    required this.initialNhmnFranceCip,
    required this.initialNhmnSpainCn,
    required this.initialNhmnBrazilAnvisa,
    required this.initialNhmnPortugalAim,
    required this.initialNhmnUsaNdc,
    required this.initialNhmnItalyAifa,
    required this.initialLocalDrugCodeUaeGcc,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialNhmnGermanyPzn;
  final String initialNhmnFranceCip;
  final String initialNhmnSpainCn;
  final String initialNhmnBrazilAnvisa;
  final String initialNhmnPortugalAim;
  final String initialNhmnUsaNdc;
  final String initialNhmnItalyAifa;
  final String initialLocalDrugCodeUaeGcc;
  final bool showFieldSkeleton;
  final void Function({
    required String nhmnGermanyPzn,
    required String nhmnFranceCip,
    required String nhmnSpainCn,
    required String nhmnBrazilAnvisa,
    required String nhmnPortugalAim,
    required String nhmnUsaNdc,
    required String nhmnItalyAifa,
    required String localDrugCodeUaeGcc,
  }) onChanged;

  @override
  State<NationalIdentifiersGroupWidget> createState() =>
      _NationalIdentifiersGroupWidgetState();
}

class _NationalIdentifiersGroupWidgetState
    extends State<NationalIdentifiersGroupWidget> {
  late final TextEditingController _nhmnGermanyPznController;
  late final TextEditingController _nhmnFranceCipController;
  late final TextEditingController _nhmnSpainCnController;
  late final TextEditingController _nhmnBrazilAnvisaController;
  late final TextEditingController _nhmnPortugalAimController;
  late final TextEditingController _nhmnUsaNdcController;
  late final TextEditingController _nhmnItalyAifaController;
  late final TextEditingController _localDrugCodeUaeGccController;

  @override
  void initState() {
    super.initState();
    _nhmnGermanyPznController = TextEditingController(text: widget.initialNhmnGermanyPzn);
    _nhmnFranceCipController = TextEditingController(text: widget.initialNhmnFranceCip);
    _nhmnSpainCnController = TextEditingController(text: widget.initialNhmnSpainCn);
    _nhmnBrazilAnvisaController = TextEditingController(text: widget.initialNhmnBrazilAnvisa);
    _nhmnPortugalAimController = TextEditingController(text: widget.initialNhmnPortugalAim);
    _nhmnUsaNdcController = TextEditingController(text: widget.initialNhmnUsaNdc);
    _nhmnItalyAifaController = TextEditingController(text: widget.initialNhmnItalyAifa);
    _localDrugCodeUaeGccController =
        TextEditingController(text: widget.initialLocalDrugCodeUaeGcc);

    _nhmnGermanyPznController.addListener(_emitChange);
    _nhmnFranceCipController.addListener(_emitChange);
    _nhmnSpainCnController.addListener(_emitChange);
    _nhmnBrazilAnvisaController.addListener(_emitChange);
    _nhmnPortugalAimController.addListener(_emitChange);
    _nhmnUsaNdcController.addListener(_emitChange);
    _nhmnItalyAifaController.addListener(_emitChange);
    _localDrugCodeUaeGccController.addListener(_emitChange);
  }

  @override
  void dispose() {
    _nhmnGermanyPznController.dispose();
    _nhmnFranceCipController.dispose();
    _nhmnSpainCnController.dispose();
    _nhmnBrazilAnvisaController.dispose();
    _nhmnPortugalAimController.dispose();
    _nhmnUsaNdcController.dispose();
    _nhmnItalyAifaController.dispose();
    _localDrugCodeUaeGccController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      nhmnGermanyPzn: _nhmnGermanyPznController.text,
      nhmnFranceCip: _nhmnFranceCipController.text,
      nhmnSpainCn: _nhmnSpainCnController.text,
      nhmnBrazilAnvisa: _nhmnBrazilAnvisaController.text,
      nhmnPortugalAim: _nhmnPortugalAimController.text,
      nhmnUsaNdc: _nhmnUsaNdcController.text,
      nhmnItalyAifa: _nhmnItalyAifaController.text,
      localDrugCodeUaeGcc: _localDrugCodeUaeGccController.text,
    );
  }

  Widget _field(
    TextEditingController controller,
    String fieldName,
    String label, {
    required int maxLength,
    String? Function(String?)? validator,
  }) {
    return GtinValidatedField(
      controller: controller,
      fieldName: fieldName,
      label: label,
      maxLength: maxLength,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      readOnly: !widget.isEditing,
      validator: validator,
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
            'National / regional identifiers',
            padding: EdgeInsets.only(bottom: 12),
          ),
          _field(
            _nhmnGermanyPznController,
            'nhmnGermanyPzn',
            'Germany (PZN)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnGermanyPzn,
          ),
          _field(
            _nhmnFranceCipController,
            'nhmnFranceCip',
            'France (CIP)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnFranceCip,
          ),
          _field(
            _nhmnSpainCnController,
            'nhmnSpainCn',
            'Spain (CN)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnSpainCn,
          ),
          _field(
            _nhmnBrazilAnvisaController,
            'nhmnBrazilAnvisa',
            'Brazil (ANVISA)',
            maxLength: 30,
            validator: PharmaFieldValidators.validateNhmnBrazilAnvisa,
          ),
          _field(
            _nhmnPortugalAimController,
            'nhmnPortugalAim',
            'Portugal (AIM)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnPortugalAim,
          ),
          _field(
            _nhmnUsaNdcController,
            'nhmnUsaNdc',
            'USA (NDC national placeholder)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnUsaNdc,
          ),
          _field(
            _nhmnItalyAifaController,
            'nhmnItalyAifa',
            'Italy (AIFA)',
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnItalyAifa,
          ),
          _field(
            _localDrugCodeUaeGccController,
            'localDrugCodeUaeGcc',
            'UAE / GCC local drug code',
            maxLength: 30,
            validator: PharmaFieldValidators.validateLocalDrugCodeUaeGcc,
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
                'National / regional identifiers',
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
