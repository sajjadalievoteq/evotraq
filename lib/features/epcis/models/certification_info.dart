import 'package:equatable/equatable.dart';

/// Model class representing certification information in EPCIS 2.0
class CertificationInfo extends Equatable {
  /// Certificate identifier
  final String? certificateId;
  
  /// Certificate standard (e.g., ISO, GS1, etc.)
  final String? certificationStandard;
  
  /// Type of certification (e.g., Organic, Fair Trade, etc.)
  final String? certificationType;
  
  /// Issuing agency/body
  final String? certificationAgency;
  
  /// Date the certification was issued
  final DateTime? issueDate;
  
  /// Date the certification expires
  final DateTime? expirationDate;
  
  /// Document URL for verifying the certification
  final String? documentUrl;
  
  /// Additional certification remarks or notes
  final String? remarks;

  /// Creates a new CertificationInfo instance
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

  /// Creates a copy with the given fields replaced with new values
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

  /// Convert from JSON
  factory CertificationInfo.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field names between backend and frontend
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
      // Return an empty object rather than throwing an exception
      return const CertificationInfo();
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    // Map to both backend and frontend field names to ensure compatibility
    if (certificateId != null) {
      data['certificateId'] = certificateId;
      data['certificateNumber'] = certificateId; // Backend field name
    }
    
    if (certificationStandard != null) data['certificationStandard'] = certificationStandard;
    if (certificationType != null) data['certificationType'] = certificationType;
    if (certificationAgency != null) data['certificationAgency'] = certificationAgency;
    
    if (issueDate != null) data['issueDate'] = issueDate!.toIso8601String();
    
    if (expirationDate != null) {
      data['expirationDate'] = expirationDate!.toIso8601String();
      data['certificateExpiry'] = expirationDate!.toIso8601String(); // Backend field name
    }
    
    if (documentUrl != null) data['documentUrl'] = documentUrl;
    
    if (remarks != null) {
      data['remarks'] = remarks;
      data['certificationRemarks'] = remarks; // Backend field name
    }
    
    return data;
  }

  /// Convert this object to a Map for API serialization
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
  
  /// Create a CertificationInfo from a Map (typically from API)
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
