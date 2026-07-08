class QuantityElement {
  final String epcClass;
  
  final double quantity;
  
  final String? uom;

  QuantityElement({
    required this.epcClass,
    required this.quantity,
    this.uom,
  });

  factory QuantityElement.fromJson(Map<String, dynamic> json) {
    return QuantityElement(
      epcClass: json['epcClass'],
      quantity: json['quantity'].toDouble(),
      uom: json['uom'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'quantity': quantity,
    };
    
    if (epcClass.startsWith('urn:epc:idpat:')) {
      data['epcClass'] = epcClass;
    } else {
      data['epcClass'] = 'urn:epc:idpat:gtin:${epcClass}';
    }
    
    if (uom != null) {
      data['uom'] = uom;
    }
    
    return data;
  }
}

class SourceDestination {
  final String type;
  
  final String id;

  SourceDestination({
    required this.type,
    required this.id,
  });

  factory SourceDestination.fromJson(Map<String, dynamic> json) {
    String typeValue = '';
    String idValue = '';
    
    if (json.containsKey('sourceType')) {
      typeValue = json['sourceType'] ?? '';
      idValue = json['sourceID'] ?? '';
    }
    else if (json.containsKey('destinationType')) {
      typeValue = json['destinationType'] ?? '';
      idValue = json['destinationID'] ?? '';
    }
    else {
      typeValue = json['type'] ?? '';
      idValue = json['id'] ?? '';
    }
    
    return SourceDestination(
      type: typeValue,
      id: idValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }
}

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
