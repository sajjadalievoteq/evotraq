/// Partner credential model for B2B API authentication
class PartnerCredential {
  final String id;
  final String partnerId;
  final CredentialType credentialType;
  final String? clientId;
  final List<String> scopes;
  final int rateLimitPerMinute;
  final bool active;
  final DateTime? expiresAt;
  final DateTime createdAt;

  PartnerCredential({
    required this.id,
    required this.partnerId,
    required this.credentialType,
    this.clientId,
    required this.scopes,
    required this.rateLimitPerMinute,
    required this.active,
    this.expiresAt,
    required this.createdAt,
  });

  factory PartnerCredential.fromJson(Map<String, dynamic> json) {
    // Parse scopes - can be a string (comma-separated) or a list
    List<String> parseScopes(dynamic scopesData) {
      if (scopesData == null) return [];
      if (scopesData is List) return List<String>.from(scopesData);
      if (scopesData is String) return scopesData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return [];
    }
    
    return PartnerCredential(
      id: json['id'] ?? '',
      partnerId: json['partnerId'] ?? '',
      // Backend returns 'authType', frontend model uses 'credentialType'
      credentialType: CredentialType.fromString(json['authType'] ?? json['credentialType'] ?? 'API_KEY'),
      clientId: json['clientId'],
      scopes: parseScopes(json['scopes']),
      rateLimitPerMinute: json['rateLimitPerMinute'] ?? 60,
      active: json['active'] ?? json['isActive'] ?? true,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  
  String get statusText {
    if (!active) return 'Revoked';
    if (isExpired) return 'Expired';
    return 'Active';
  }
}

enum CredentialType {
  apiKey('API_KEY', 'API Key'),
  oauth2ClientCredentials('OAUTH2_CLIENT_CREDENTIALS', 'OAuth2 Client Credentials'),
  mtlsCertificate('MTLS_CERTIFICATE', 'mTLS Certificate');

  final String value;
  final String displayName;
  const CredentialType(this.value, this.displayName);

  static CredentialType fromString(String value) {
    return CredentialType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CredentialType.apiKey,
    );
  }
}

/// Response when creating a new API key credential
class ApiKeyCredentialResponse {
  final String credentialId;
  final String apiKey;
  final List<String> scopes;
  final int rateLimitPerMinute;
  final DateTime? expiresAt;

  ApiKeyCredentialResponse({
    required this.credentialId,
    required this.apiKey,
    required this.scopes,
    required this.rateLimitPerMinute,
    this.expiresAt,
  });

  factory ApiKeyCredentialResponse.fromJson(Map<String, dynamic> json) {
    // Parse scopes - can be a string (comma-separated) or a list
    List<String> parseScopes(dynamic scopesData) {
      if (scopesData == null) return [];
      if (scopesData is List) return List<String>.from(scopesData);
      if (scopesData is String) return scopesData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return [];
    }
    
    return ApiKeyCredentialResponse(
      credentialId: json['credentialId'] ?? json['id'] ?? '',
      apiKey: json['apiKey'] ?? '',
      scopes: parseScopes(json['scopes']),
      rateLimitPerMinute: json['rateLimitPerMinute'] ?? 60,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }
}

/// Response when creating OAuth2 credentials
class OAuth2CredentialResponse {
  final String credentialId;
  final String clientId;
  final String clientSecret;
  final List<String> scopes;
  final int rateLimitPerMinute;
  final DateTime? expiresAt;

  OAuth2CredentialResponse({
    required this.credentialId,
    required this.clientId,
    required this.clientSecret,
    required this.scopes,
    required this.rateLimitPerMinute,
    this.expiresAt,
  });

  factory OAuth2CredentialResponse.fromJson(Map<String, dynamic> json) {
    // Parse scopes - can be a string (comma-separated) or a list
    List<String> parseScopes(dynamic scopesData) {
      if (scopesData == null) return [];
      if (scopesData is List) return List<String>.from(scopesData);
      if (scopesData is String) return scopesData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return [];
    }
    
    return OAuth2CredentialResponse(
      credentialId: json['credentialId'] ?? json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      scopes: parseScopes(json['scopes']),
      rateLimitPerMinute: json['rateLimitPerMinute'] ?? 60,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }
}
