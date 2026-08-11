import 'package:equatable/equatable.dart';

double? _jsonDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

int? _jsonInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

enum DeaSchedule {
  scheduleI,
  scheduleII,
  scheduleIII,
  scheduleIV,
  scheduleV,
  none,
}

extension DeaScheduleExtension on DeaSchedule {
  String get value {
    switch (this) {
      case DeaSchedule.scheduleI:
        return 'I';
      case DeaSchedule.scheduleII:
        return 'II';
      case DeaSchedule.scheduleIII:
        return 'III';
      case DeaSchedule.scheduleIV:
        return 'IV';
      case DeaSchedule.scheduleV:
        return 'V';
      case DeaSchedule.none:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case DeaSchedule.scheduleI:
        return 'Schedule I - High abuse potential, no accepted medical use';
      case DeaSchedule.scheduleII:
        return 'Schedule II - High abuse potential, severe dependence';
      case DeaSchedule.scheduleIII:
        return 'Schedule III - Moderate abuse potential';
      case DeaSchedule.scheduleIV:
        return 'Schedule IV - Low abuse potential';
      case DeaSchedule.scheduleV:
        return 'Schedule V - Lowest abuse potential';
      case DeaSchedule.none:
        return 'Not a Controlled Substance';
    }
  }

  static DeaSchedule fromString(String? value) {
    if (value == null || value.isEmpty) return DeaSchedule.none;
    switch (value.toUpperCase()) {
      case 'I':
        return DeaSchedule.scheduleI;
      case 'II':
        return DeaSchedule.scheduleII;
      case 'III':
        return DeaSchedule.scheduleIII;
      case 'IV':
        return DeaSchedule.scheduleIV;
      case 'V':
        return DeaSchedule.scheduleV;
      default:
        return DeaSchedule.none;
    }
  }
}

enum PregnancyCategory {
  categoryA,
  categoryB,
  categoryC,
  categoryD,
  categoryX,
  notClassified,
}

extension PregnancyCategoryExtension on PregnancyCategory {
  String get value {
    switch (this) {
      case PregnancyCategory.categoryA:
        return 'A';
      case PregnancyCategory.categoryB:
        return 'B';
      case PregnancyCategory.categoryC:
        return 'C';
      case PregnancyCategory.categoryD:
        return 'D';
      case PregnancyCategory.categoryX:
        return 'X';
      case PregnancyCategory.notClassified:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case PregnancyCategory.categoryA:
        return 'Category A - Adequate studies show no risk';
      case PregnancyCategory.categoryB:
        return 'Category B - No risk in animal studies';
      case PregnancyCategory.categoryC:
        return 'Category C - Risk cannot be ruled out';
      case PregnancyCategory.categoryD:
        return 'Category D - Positive evidence of risk';
      case PregnancyCategory.categoryX:
        return 'Category X - Contraindicated in pregnancy';
      case PregnancyCategory.notClassified:
        return 'Not Classified';
    }
  }

  static PregnancyCategory fromString(String? value) {
    if (value == null || value.isEmpty) return PregnancyCategory.notClassified;
    switch (value.toUpperCase()) {
      case 'A':
        return PregnancyCategory.categoryA;
      case 'B':
        return PregnancyCategory.categoryB;
      case 'C':
        return PregnancyCategory.categoryC;
      case 'D':
        return PregnancyCategory.categoryD;
      case 'X':
        return PregnancyCategory.categoryX;
      default:
        return PregnancyCategory.notClassified;
    }
  }
}

class ActiveIngredient extends Equatable {
  final String name;
  final double? amount;
  final String? unit;
  final String substanceRoleCode;
  final int sequence;
  final String? basisOfStrength;

  ActiveIngredient({
    required this.name,
    this.amount,
    this.unit,
    this.substanceRoleCode = 'ACTIVE',
    this.sequence = 0,
    this.basisOfStrength,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      name: json['name'] ?? '',
      amount: _jsonDouble(json['amount']),
      unit: json['unit'] as String?,
      substanceRoleCode: json['substanceRoleCode'] as String? ?? 'ACTIVE',
      sequence: _jsonInt(json['sequence']) ?? 0,
      basisOfStrength: json['basisOfStrength'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'substanceRoleCode': substanceRoleCode,
      'sequence': sequence,
      'basisOfStrength': basisOfStrength,
    };
  }

  @override
  List<Object?> get props => [
    name,
    amount,
    unit,
    substanceRoleCode,
    sequence,
    basisOfStrength,
  ];
}
