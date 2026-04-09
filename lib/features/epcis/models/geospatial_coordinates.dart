import 'package:equatable/equatable.dart';

/// Model class representing geospatial coordinates in EPCIS 2.0
class GeospatialCoordinates extends Equatable {
  /// Latitude in decimal degrees
  final double latitude;
  
  /// Longitude in decimal degrees
  final double longitude;
  
  /// Altitude in meters (optional)
  final double? altitude;
  
  /// Coordinate system or datum (e.g., WGS84)
  final String? coordinateSystem;
  
  /// Horizontal accuracy in meters
  final double? horizontalAccuracy;
  
  /// Vertical accuracy in meters
  final double? verticalAccuracy;
  
  /// Location name or label
  final String? name;
  
  /// Creates a new GeospatialCoordinates instance
  const GeospatialCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.coordinateSystem = 'WGS84', // Default to WGS84
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.name,
  });

  /// Creates a copy with the given fields replaced with new values
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

  /// Convert from JSON
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

  /// Convert to JSON
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
  
  /// Calculate distance to another location in kilometers using the haversine formula
  double distanceTo(GeospatialCoordinates other) {
    // Earth's radius in kilometers
    const double earthRadius = 6371.0;
    
    // Convert latitude and longitude from degrees to radians
    final double lat1 = _degreesToRadians(latitude);
    final double lon1 = _degreesToRadians(longitude);
    final double lat2 = _degreesToRadians(other.latitude);
    final double lon2 = _degreesToRadians(other.longitude);
    
    // Haversine formula
    final double dlon = lon2 - lon1;
    final double dlat = lat2 - lat1;
    final double a = _sin2(dlat / 2.0) +
        _cos(lat1) * _cos(lat2) * _sin2(dlon / 2.0);
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    final double distance = earthRadius * c;
    
    return distance;
  }
  
  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }
  
  /// Sine of an angle in radians
  double _sin(double radians) {
    return _sincos(radians, true);
  }
  
  /// Square of sine
  double _sin2(double radians) {
    final double s = _sin(radians);
    return s * s;
  }
  
  /// Cosine of an angle in radians
  double _cos(double radians) {
    return _sincos(radians, false);
  }
  
  /// Calculate sin or cos using Taylor series
  double _sincos(double radians, bool isSin) {
    // For better precision, use Dart's math library instead of custom implementation
    // This is a simple implementation for illustration
    if (isSin) {
      return radians - (radians * radians * radians) / 6 + 
          (radians * radians * radians * radians * radians) / 120;
    } else {
      return 1 - (radians * radians) / 2 + 
          (radians * radians * radians * radians) / 24;
    }
  }
  
  /// Square root approximation
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double r = x / 2;
    for (int i = 0; i < 10; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
  
  /// Arctangent of y/x
  double _atan2(double y, double x) {
    // Simple approximation - in a real app, import dart:math instead
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0) {
      return y >= 0 ? _atan(y / x) + 3.141592653589793 : _atan(y / x) - 3.141592653589793;
    } else {
      return y > 0 ? 1.5707963267948966 : -1.5707963267948966;
    }
  }
  
  /// Arctangent approximation
  double _atan(double x) {
    // Simple approximation
    return x / (1 + 0.28 * x * x);
  }
}
