import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// Maps legacy operational location subtype ↔ dropdown labels / [LocationType].
class GlnLocationTypeMapper {
  GlnLocationTypeMapper._();

  static LocationType parseDropdown(String? type) {
    switch (type) {
      case 'Manufacturing Site':
        return LocationType.manufacturing_site;
      case 'Warehouse':
        return LocationType.warehouse;
      case 'Distribution Center':
        return LocationType.distribution_center;
      case 'Pharmacy':
        return LocationType.pharmacy;
      case 'Hospital':
        return LocationType.hospital;
      case 'Wholesaler':
        return LocationType.wholesaler;
      case 'Clinic':
        return LocationType.clinic;
      case 'Regulatory Body':
        return LocationType.regulatory_body;
      default:
        return LocationType.other;
    }
  }

  static String toDropdownLabel(LocationType type) {
    switch (type) {
      case LocationType.manufacturing_site:
        return 'Manufacturing Site';
      case LocationType.warehouse:
        return 'Warehouse';
      case LocationType.distribution_center:
        return 'Distribution Center';
      case LocationType.pharmacy:
        return 'Pharmacy';
      case LocationType.hospital:
        return 'Hospital';
      case LocationType.wholesaler:
        return 'Wholesaler';
      case LocationType.clinic:
        return 'Clinic';
      case LocationType.regulatory_body:
        return 'Regulatory Body';
      case LocationType.other:
        return 'Other';
    }
  }
}
