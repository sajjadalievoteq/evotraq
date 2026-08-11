import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/pharma_padded_validated_field.dart';

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
  })
  onChanged;

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
    _nhmnGermanyPznController = TextEditingController(
      text: widget.initialNhmnGermanyPzn,
    );
    _nhmnFranceCipController = TextEditingController(
      text: widget.initialNhmnFranceCip,
    );
    _nhmnSpainCnController = TextEditingController(
      text: widget.initialNhmnSpainCn,
    );
    _nhmnBrazilAnvisaController = TextEditingController(
      text: widget.initialNhmnBrazilAnvisa,
    );
    _nhmnPortugalAimController = TextEditingController(
      text: widget.initialNhmnPortugalAim,
    );
    _nhmnUsaNdcController = TextEditingController(
      text: widget.initialNhmnUsaNdc,
    );
    _nhmnItalyAifaController = TextEditingController(
      text: widget.initialNhmnItalyAifa,
    );
    _localDrugCodeUaeGccController = TextEditingController(
      text: widget.initialLocalDrugCodeUaeGcc,
    );

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

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PharmaPaddedValidatedField(
            controller: _nhmnGermanyPznController,
            fieldName: 'nhmnGermanyPzn',
            label: 'Germany (PZN)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnGermanyPzn,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnFranceCipController,
            fieldName: 'nhmnFranceCip',
            label: 'France (CIP)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnFranceCip,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnSpainCnController,
            fieldName: 'nhmnSpainCn',
            label: 'Spain (CN)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnSpainCn,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnBrazilAnvisaController,
            fieldName: 'nhmnBrazilAnvisa',
            label: 'Brazil (ANVISA)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 30,
            validator: PharmaFieldValidators.validateNhmnBrazilAnvisa,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnPortugalAimController,
            fieldName: 'nhmnPortugalAim',
            label: 'Portugal (AIM)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnPortugalAim,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnUsaNdcController,
            fieldName: 'nhmnUsaNdc',
            label: 'USA (NDC national placeholder)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnUsaNdc,
          ),
          PharmaPaddedValidatedField(
            controller: _nhmnItalyAifaController,
            fieldName: 'nhmnItalyAifa',
            label: 'Italy (AIFA)',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 20,
            validator: PharmaFieldValidators.validateNhmnItalyAifa,
          ),
          PharmaPaddedValidatedField(
            controller: _localDrugCodeUaeGccController,
            fieldName: 'localDrugCodeUaeGcc',
            label: 'UAE / GCC local drug code',
            readOnly: !widget.isEditing,
            padding: EdgeInsets.zero,
            maxLength: 30,
            validator: PharmaFieldValidators.validateLocalDrugCodeUaeGcc,
          ),
        ],
      ),
    );

    return Gs1GroupCard(
      title: 'National / regional identifiers',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 2,
      child: content,
    );
  }
}
