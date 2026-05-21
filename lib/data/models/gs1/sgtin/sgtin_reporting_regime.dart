import 'package:equatable/equatable.dart';

class SGTINReportingRegime extends Equatable {
  final int? id;
  final String? uuid;
  final int sgtinId;
  final String regimeType;
  final String enrollmentStatus;
  final String? enrollmentDate;
  final String? unenrollmentDate;
  final String? regulatoryProductCode;
  final String? nationalDrugCode;
  final String? reimbursementCode;

  const SGTINReportingRegime({
    this.id,
    this.uuid,
    required this.sgtinId,
    required this.regimeType,
    required this.enrollmentStatus,
    this.enrollmentDate,
    this.unenrollmentDate,
    this.regulatoryProductCode,
    this.nationalDrugCode,
    this.reimbursementCode,
  });

  factory SGTINReportingRegime.fromJson(Map<String, dynamic> json) =>
      SGTINReportingRegime(
        id: json['id'] as int?,
        uuid: json['uuid'] as String?,
        sgtinId: json['sgtinId'] as int,
        regimeType: json['regimeType'] as String,
        enrollmentStatus: json['enrollmentStatus'] as String,
        enrollmentDate: json['enrollmentDate'] as String?,
        unenrollmentDate: json['unenrollmentDate'] as String?,
        regulatoryProductCode: json['regulatoryProductCode'] as String?,
        nationalDrugCode: json['nationalDrugCode'] as String?,
        reimbursementCode: json['reimbursementCode'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (uuid != null) 'uuid': uuid,
        'sgtinId': sgtinId,
        'regimeType': regimeType,
        'enrollmentStatus': enrollmentStatus,
        if (enrollmentDate != null) 'enrollmentDate': enrollmentDate,
        if (unenrollmentDate != null) 'unenrollmentDate': unenrollmentDate,
        if (regulatoryProductCode != null)
          'regulatoryProductCode': regulatoryProductCode,
        if (nationalDrugCode != null) 'nationalDrugCode': nationalDrugCode,
        if (reimbursementCode != null) 'reimbursementCode': reimbursementCode,
      };

  SGTINReportingRegime copyWith({
    int? id,
    String? uuid,
    int? sgtinId,
    String? regimeType,
    String? enrollmentStatus,
    String? enrollmentDate,
    String? unenrollmentDate,
    String? regulatoryProductCode,
    String? nationalDrugCode,
    String? reimbursementCode,
  }) =>
      SGTINReportingRegime(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        sgtinId: sgtinId ?? this.sgtinId,
        regimeType: regimeType ?? this.regimeType,
        enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
        enrollmentDate: enrollmentDate ?? this.enrollmentDate,
        unenrollmentDate: unenrollmentDate ?? this.unenrollmentDate,
        regulatoryProductCode:
            regulatoryProductCode ?? this.regulatoryProductCode,
        nationalDrugCode: nationalDrugCode ?? this.nationalDrugCode,
        reimbursementCode: reimbursementCode ?? this.reimbursementCode,
      );

  @override
  List<Object?> get props => [
        id, uuid, sgtinId, regimeType, enrollmentStatus,
        enrollmentDate, unenrollmentDate, regulatoryProductCode,
        nationalDrugCode, reimbursementCode,
      ];
}
