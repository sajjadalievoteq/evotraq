// QuantityElement represents GS1 EPCIS quantity element with EPC class, quantity, and unit of measure
class QuantityElement {
  /// EPC class for this quantity
  final String epcClass;
  
  /// Quantity value
  final double quantity;
  
  /// Unit of Measure
  final String? uom;

  QuantityElement({
    required this.epcClass,
    required this.quantity,
    this.uom,
  });

  /// Create a QuantityElement from a JSON object
  factory QuantityElement.fromJson(Map<String, dynamic> json) {
    return QuantityElement(
      epcClass: json['epcClass'],
      quantity: json['quantity'].toDouble(),
      uom: json['uom'],
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'quantity': quantity,
    };
    
    // Ensure epcClass matches the required pattern by adding urn prefix if needed
    if (epcClass.startsWith('urn:epc:idpat:')) {
      data['epcClass'] = epcClass;
    } else {
      // Add the proper URN prefix
      data['epcClass'] = 'urn:epc:idpat:gtin:${epcClass}';
    }
    
    if (uom != null) {
      data['uom'] = uom;
    }
    
    return data;
  }
}

/// SourceDestination represents a source or destination in the supply chain
class SourceDestination {
  /// Type of source/destination
  final String type;
  
  /// Identifier for the source/destination
  final String id;

  SourceDestination({
    required this.type,
    required this.id,
  });

  /// Create a SourceDestination from a JSON object
  factory SourceDestination.fromJson(Map<String, dynamic> json) {
    // Handle both source and destination field naming patterns
    String typeValue = '';
    String idValue = '';
    
    // Check for source-specific field names
    if (json.containsKey('sourceType')) {
      typeValue = json['sourceType'] ?? '';
      idValue = json['sourceID'] ?? '';
    }
    // Check for destination-specific field names
    else if (json.containsKey('destinationType')) {
      typeValue = json['destinationType'] ?? '';
      idValue = json['destinationID'] ?? '';
    }
    // Fallback to legacy field names for backward compatibility
    else {
      typeValue = json['type'] ?? '';
      idValue = json['id'] ?? '';
    }
    
    return SourceDestination(
      type: typeValue,
      id: idValue,
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }
}

/// Enumeration of EPCIS versions
enum EPCISVersion {
  v1_3('1.3'),
  v2_0('2.0');

  final String value;
  const EPCISVersion(this.value);

  static EPCISVersion fromString(String? version) {
    if (version == null) return EPCISVersion.v1_3;
    return version == '2.0' ? EPCISVersion.v2_0 : EPCISVersion.v1_3;
  }

  @override
  String toString() => value;
}
