import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';

class DosageRouteIngredientRow {
  DosageRouteIngredientRow({ActiveIngredient? initial, this.onChanged}) {
    if (initial != null) {
      name.text = initial.name;
      amount.text = initial.amount?.toString() ?? '';
      unit.text = initial.unit ?? '';
      substanceRoleCode.text = initial.substanceRoleCode.isEmpty
          ? 'ACTIVE'
          : initial.substanceRoleCode;
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
  final TextEditingController substanceRoleCode = TextEditingController(
    text: 'ACTIVE',
  );
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
      amount: amount.text.trim().isEmpty
          ? null
          : double.tryParse(amount.text.trim()),
      unit: unit.text.trim().isEmpty ? null : unit.text.trim(),
      substanceRoleCode: substanceRoleCode.text.trim().isEmpty
          ? 'ACTIVE'
          : substanceRoleCode.text.trim(),
      sequence: seq ?? 0,
      basisOfStrength: basisOfStrength.text.trim().isEmpty
          ? null
          : basisOfStrength.text.trim(),
    );
  }
}
