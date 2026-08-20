enum HealthcareFacilityType {
  hospital,
  pharmacy,
  clinic,
  longTermCare,
  homeHealthcare,
  wholesaler,
  distributor,
  manufacturer,
  repackager,
  other,
}

extension HealthcareFacilityTypeExtension on HealthcareFacilityType {
  String get value {
    switch (this) {
      case HealthcareFacilityType.hospital:
        return 'HOSPITAL';
      case HealthcareFacilityType.pharmacy:
        return 'PHARMACY';
      case HealthcareFacilityType.clinic:
        return 'CLINIC';
      case HealthcareFacilityType.longTermCare:
        return 'LONG_TERM_CARE';
      case HealthcareFacilityType.homeHealthcare:
        return 'HOME_HEALTHCARE';
      case HealthcareFacilityType.wholesaler:
        return 'WHOLESALER';
      case HealthcareFacilityType.distributor:
        return 'DISTRIBUTOR';
      case HealthcareFacilityType.manufacturer:
        return 'MANUFACTURER';
      case HealthcareFacilityType.repackager:
        return 'REPACKAGER';
      case HealthcareFacilityType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case HealthcareFacilityType.hospital:
        return 'Hospital';
      case HealthcareFacilityType.pharmacy:
        return 'Pharmacy';
      case HealthcareFacilityType.clinic:
        return 'Clinic';
      case HealthcareFacilityType.longTermCare:
        return 'Long Term Care';
      case HealthcareFacilityType.homeHealthcare:
        return 'Home Healthcare';
      case HealthcareFacilityType.wholesaler:
        return 'Wholesaler';
      case HealthcareFacilityType.distributor:
        return 'Distributor';
      case HealthcareFacilityType.manufacturer:
        return 'Manufacturer';
      case HealthcareFacilityType.repackager:
        return 'Repackager';
      case HealthcareFacilityType.other:
        return 'Other';
    }
  }

  static HealthcareFacilityType fromString(String? value) {
    if (value == null || value.isEmpty) return HealthcareFacilityType.other;
    switch (value.toUpperCase()) {
      case 'HOSPITAL':
        return HealthcareFacilityType.hospital;
      case 'PHARMACY':
        return HealthcareFacilityType.pharmacy;
      case 'CLINIC':
        return HealthcareFacilityType.clinic;
      case 'LONG_TERM_CARE':
        return HealthcareFacilityType.longTermCare;
      case 'HOME_HEALTHCARE':
        return HealthcareFacilityType.homeHealthcare;
      case 'WHOLESALER':
        return HealthcareFacilityType.wholesaler;
      case 'DISTRIBUTOR':
        return HealthcareFacilityType.distributor;
      case 'MANUFACTURER':
        return HealthcareFacilityType.manufacturer;
      case 'REPACKAGER':
        return HealthcareFacilityType.repackager;
      default:
        return HealthcareFacilityType.other;
    }
  }
}
