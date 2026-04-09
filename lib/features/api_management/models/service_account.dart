/// Service Account model for internal M2M authentication
/// 
/// Service accounts are used by the Integration Layer to authenticate
/// when calling the Core System APIs.

class ServiceAccount {
  final String id;
  final String clientId;
  final String name;
  final String? description;
  final bool isActive;
  final List<String> allowedIps;
  final List<String> allowedEndpoints;
  final int rateLimitPerMinute;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final String? createdBy;

  ServiceAccount({
    required this.id,
    required this.clientId,
    required this.name,
    this.description,
    required this.isActive,
    this.allowedIps = const [],
    this.allowedEndpoints = const [],
    this.rateLimitPerMinute = 1000,
    required this.createdAt,
    this.updatedAt,
    this.lastUsedAt,
    this.expiresAt,
    this.createdBy,
  });

  factory ServiceAccount.fromJson(Map<String, dynamic> json) {
    return ServiceAccount(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      allowedIps: _parseList(json['allowedIps']),
      allowedEndpoints: _parseList(json['allowedEndpoints']),
      rateLimitPerMinute: json['rateLimitPerMinute'] as int? ?? 1000,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt'] as String) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'allowedIps': allowedIps.join(','),
      'allowedEndpoints': allowedEndpoints.join(','),
      'rateLimitPerMinute': rateLimitPerMinute,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    if (value is String) {
      return value.isEmpty ? [] : value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  /// Check if the service account is expired
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Get the status text
  String get statusText {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    return 'Active';
  }

  /// Check if the account is usable (active and not expired)
  bool get isUsable => isActive && !isExpired;

  ServiceAccount copyWith({
    String? id,
    String? clientId,
    String? name,
    String? description,
    bool? isActive,
    List<String>? allowedIps,
    List<String>? allowedEndpoints,
    int? rateLimitPerMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    String? createdBy,
  }) {
    return ServiceAccount(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      allowedIps: allowedIps ?? this.allowedIps,
      allowedEndpoints: allowedEndpoints ?? this.allowedEndpoints,
      rateLimitPerMinute: rateLimitPerMinute ?? this.rateLimitPerMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// Response when creating a new service account (includes unhashed secret)
class ServiceAccountCredentials {
  final String id;
  final String clientId;
  final String clientSecret;
  final String name;

  ServiceAccountCredentials({
    required this.id,
    required this.clientId,
    required this.clientSecret,
    required this.name,
  });

  factory ServiceAccountCredentials.fromJson(Map<String, dynamic> json) {
    return ServiceAccountCredentials(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
      name: json['name'] as String,
    );
  }
}
