import 'package:equatable/equatable.dart';

class GeospatialCoordinates extends Equatable {
  final double latitude;
  
  final double longitude;
  
  final double? altitude;
  
  final String? coordinateSystem;
  
  final double? horizontalAccuracy;
  
  final double? verticalAccuracy;
  
  final String? name;
  
  const GeospatialCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.coordinateSystem = 'WGS84',
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.name,
  });

  GeospatialCoordinates copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    String? coordinateSystem,
    double? horizontalAccuracy,
    double? verticalAccuracy,
    String? name,
  }) {
    return GeospatialCoordinates(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      name: name ?? this.name,
    );
  }

  factory GeospatialCoordinates.fromJson(Map<String, dynamic> json) {
    return GeospatialCoordinates(
      latitude: (json['latitude'] is String) ? 
        double.parse(json['latitude']) : json['latitude']?.toDouble() ?? 0.0,
      longitude: (json['longitude'] is String) ? 
        double.parse(json['longitude']) : json['longitude']?.toDouble() ?? 0.0,
      altitude: json['altitude'] != null ? 
        ((json['altitude'] is String) ? 
          double.parse(json['altitude']) : json['altitude']?.toDouble()) : null,
      coordinateSystem: json['coordinateSystem'] ?? 'WGS84',
      horizontalAccuracy: json['horizontalAccuracy'] != null ? 
        ((json['horizontalAccuracy'] is String) ? 
          double.parse(json['horizontalAccuracy']) : json['horizontalAccuracy']?.toDouble()) : null,
      verticalAccuracy: json['verticalAccuracy'] != null ? 
        ((json['verticalAccuracy'] is String) ? 
          double.parse(json['verticalAccuracy']) : json['verticalAccuracy']?.toDouble()) : null,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (altitude != null) data['altitude'] = altitude;
    if (coordinateSystem != null) data['coordinateSystem'] = coordinateSystem;
    if (horizontalAccuracy != null) data['horizontalAccuracy'] = horizontalAccuracy;
    if (verticalAccuracy != null) data['verticalAccuracy'] = verticalAccuracy;
    if (name != null) data['name'] = name;
    
    return data;
  }

  @override
  List<Object?> get props => [
    latitude, longitude, altitude, coordinateSystem, 
    horizontalAccuracy, verticalAccuracy, name
  ];
  
  double distanceTo(GeospatialCoordinates other) {
    const double earthRadius = 6371.0;
    
    final double lat1 = _degreesToRadians(latitude);
    final double lon1 = _degreesToRadians(longitude);
    final double lat2 = _degreesToRadians(other.latitude);
    final double lon2 = _degreesToRadians(other.longitude);
    
    final double dlon = lon2 - lon1;
    final double dlat = lat2 - lat1;
    final double a = _sin2(dlat / 2.0) +
        _cos(lat1) * _cos(lat2) * _sin2(dlon / 2.0);
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    final double distance = earthRadius * c;
    
    return distance;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }
  
  double _sin(double radians) {
    return _sincos(radians, true);
  }
  
  double _sin2(double radians) {
    final double s = _sin(radians);
    return s * s;
  }
  
  double _cos(double radians) {
    return _sincos(radians, false);
  }
  
  double _sincos(double radians, bool isSin) {
    if (isSin) {
      return radians - (radians * radians * radians) / 6 + 
          (radians * radians * radians * radians * radians) / 120;
    } else {
      return 1 - (radians * radians) / 2 + 
          (radians * radians * radians * radians) / 24;
    }
  }
  
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x / 2;
    for (int i = 0; i < 10; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
  
  double _atan2(double y, double x) {
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0) {
      return y >= 0 ? _atan(y / x) + 3.141592653589793 : _atan(y / x) - 3.141592653589793;
    } else {
      return y > 0 ? 1.5707963267948966 : -1.5707963267948966;
    }
  }
  
  double _atan(double x) {
    return x / (1 + 0.28 * x * x);
  }
}
