import 'package:equatable/equatable.dart';

class CertificationInfo extends Equatable {
  final String? certificateId;
  
  final String? certificationStandard;
  
  final String? certificationType;
  
  final String? certificationAgency;
  
  final DateTime? issueDate;
  
  final DateTime? expirationDate;
  
  final String? documentUrl;
  
  final String? remarks;

  const CertificationInfo({
    this.certificateId,
    this.certificationStandard,
    this.certificationType,
    this.certificationAgency,
    this.issueDate,
    this.expirationDate,
    this.documentUrl,
    this.remarks,
  });

  CertificationInfo copyWith({
    String? certificateId,
    String? certificationStandard,
    String? certificationType,
    String? certificationAgency,
    DateTime? issueDate,
    DateTime? expirationDate,
    String? documentUrl,
    String? remarks,
  }) {
    return CertificationInfo(
      certificateId: certificateId ?? this.certificateId,
      certificationStandard: certificationStandard ?? this.certificationStandard,
      certificationType: certificationType ?? this.certificationType,
      certificationAgency: certificationAgency ?? this.certificationAgency,
      issueDate: issueDate ?? this.issueDate,
      expirationDate: expirationDate ?? this.expirationDate,
      documentUrl: documentUrl ?? this.documentUrl,
      remarks: remarks ?? this.remarks,
    );
  }

  factory CertificationInfo.fromJson(Map<String, dynamic> json) {
    try {
      return CertificationInfo(
        certificateId: json['certificateId'] ?? json['certificateNumber'],
        certificationStandard: json['certificationStandard'],
        certificationType: json['certificationType'],
        certificationAgency: json['certificationAgency'],
        issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
        expirationDate: json['expirationDate'] != null 
            ? DateTime.parse(json['expirationDate']) 
            : (json['certificateExpiry'] != null ? DateTime.parse(json['certificateExpiry']) : null),
        documentUrl: json['documentUrl'],
        remarks: json['certificationRemarks'] ?? json['remarks'],
      );
    } catch (e) {
      print("Error parsing certification info: $e");
      return const CertificationInfo();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    if (certificateId != null) {
      data['certificateId'] = certificateId;
      data['certificateNumber'] = certificateId;
    }
    
    if (certificationStandard != null) data['certificationStandard'] = certificationStandard;
    if (certificationType != null) data['certificationType'] = certificationType;
    if (certificationAgency != null) data['certificationAgency'] = certificationAgency;
    
    if (issueDate != null) data['issueDate'] = issueDate!.toIso8601String();
    
    if (expirationDate != null) {
      data['expirationDate'] = expirationDate!.toIso8601String();
      data['certificateExpiry'] = expirationDate!.toIso8601String();
    }
    
    if (documentUrl != null) data['documentUrl'] = documentUrl;
    
    if (remarks != null) {
      data['remarks'] = remarks;
      data['certificationRemarks'] = remarks;
    }
    
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      if (certificateId != null) 'certificateId': certificateId,
      if (certificationStandard != null) 'certificationStandard': certificationStandard,
      if (certificationType != null) 'certificationType': certificationType,
      if (certificationAgency != null) 'certificationAgency': certificationAgency,
      if (issueDate != null) 'issueDate': issueDate?.toIso8601String(),
      if (expirationDate != null) 'expirationDate': expirationDate?.toIso8601String(),
    };
  }
  
  static CertificationInfo fromMap(Map<String, dynamic> map) {
    return CertificationInfo(
      certificateId: map['certificateId'],
      certificationStandard: map['certificationStandard'],
      certificationType: map['certificationType'],
      certificationAgency: map['certificationAgency'],
      issueDate: map['issueDate'] != null ? DateTime.parse(map['issueDate']) : null,
      expirationDate: map['expirationDate'] != null ? DateTime.parse(map['expirationDate']) : null,
    );
  }

  @override
  List<Object?> get props => [
    certificateId, certificationStandard, certificationType, 
    certificationAgency, issueDate, expirationDate, 
    documentUrl, remarks
  ];
}
