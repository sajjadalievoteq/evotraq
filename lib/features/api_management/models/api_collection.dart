/// Models for API Collection Management
/// Supports granular API access control with Collections and individual API definitions

import 'dart:convert';

class ApiCollection {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String version;
  final String? category;
  final String? icon;
  final bool isPublic;
  final bool isActive;
  final int? rateLimitPerMinute;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ApiDefinition>? apiDefinitions;

  ApiCollection({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.version = '1.0',
    this.category,
    this.icon,
    this.isPublic = false,
    this.isActive = true,
    this.rateLimitPerMinute,
    required this.createdAt,
    required this.updatedAt,
    this.apiDefinitions,
  });

  factory ApiCollection.fromJson(Map<String, dynamic> json) {
    return ApiCollection(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as String? ?? '1.0',
      category: json['category'] as String?,
      icon: json['icon'] as String?,
      isPublic: json['isPublic'] as bool? ?? json['public'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      rateLimitPerMinute: json['rateLimitPerMinute'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      apiDefinitions: json['apiDefinitions'] != null
          ? (json['apiDefinitions'] as List)
              .map((e) => ApiDefinition.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'version': version,
      'category': category,
      'icon': icon,
      'isPublic': isPublic,
      'isActive': isActive,
      'rateLimitPerMinute': rateLimitPerMinute,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ApiCollection copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? version,
    String? category,
    String? icon,
    bool? isPublic,
    bool? isActive,
    int? rateLimitPerMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ApiDefinition>? apiDefinitions,
  }) {
    return ApiCollection(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      rateLimitPerMinute: rateLimitPerMinute ?? this.rateLimitPerMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      apiDefinitions: apiDefinitions ?? this.apiDefinitions,
    );
  }

  int get apiCount => apiDefinitions?.length ?? 0;

  String get statusText => isActive ? 'Active' : 'Inactive';

  String get visibilityText => isPublic ? 'Public' : 'Private';
}

class ApiDefinition {
  final String id;
  final String collectionId;
  final String code;
  final String name;
  final String? description;
  final String httpMethod;
  final String pathPattern;
  final String? requestContentType;
  final String? responseContentType;
  final int timeoutSeconds;
  final int? cacheTtlSeconds;
  final int? rateLimitPerMinute;
  final List<String>? tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Documentation fields for Postman export
  final String? requestBodySchema;
  final String? requestBodyExample;
  final String? responseBodySchema;
  final String? responseBodyExample;
  final List<ApiParameter>? queryParameters;
  final List<ApiParameter>? pathParameters;
  final List<ApiHeader>? customHeaders;

  ApiDefinition({
    required this.id,
    required this.collectionId,
    required this.code,
    required this.name,
    this.description,
    required this.httpMethod,
    required this.pathPattern,
    this.requestContentType,
    this.responseContentType,
    this.timeoutSeconds = 30,
    this.cacheTtlSeconds,
    this.rateLimitPerMinute,
    this.tags,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.requestBodySchema,
    this.requestBodyExample,
    this.responseBodySchema,
    this.responseBodyExample,
    this.queryParameters,
    this.pathParameters,
    this.customHeaders,
  });

  factory ApiDefinition.fromJson(Map<String, dynamic> json) {
    return ApiDefinition(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String? ?? 
                    (json['collection'] != null ? json['collection']['id'] as String : ''),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      httpMethod: json['httpMethod'] as String,
      pathPattern: json['pathPattern'] as String,
      requestContentType: json['requestContentType'] as String?,
      responseContentType: json['responseContentType'] as String?,
      timeoutSeconds: json['timeoutSeconds'] as int? ?? 30,
      cacheTtlSeconds: json['cacheTtlSeconds'] as int?,
      rateLimitPerMinute: json['rateLimitPerMinute'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      requestBodySchema: json['requestBodySchema'] as String?,
      requestBodyExample: json['requestBodyExample'] as String?,
      responseBodySchema: json['responseBodySchema'] as String?,
      responseBodyExample: json['responseBodyExample'] as String?,
      queryParameters: json['queryParameters'] != null
          ? (json['queryParameters'] is String 
              ? ApiParameter.fromJsonString(json['queryParameters'] as String)
              : (json['queryParameters'] as List).map((e) => ApiParameter.fromJson(e)).toList())
          : null,
      pathParameters: json['pathParameters'] != null
          ? (json['pathParameters'] is String 
              ? ApiParameter.fromJsonString(json['pathParameters'] as String)
              : (json['pathParameters'] as List).map((e) => ApiParameter.fromJson(e)).toList())
          : null,
      customHeaders: json['customHeaders'] != null
          ? (json['customHeaders'] is String 
              ? ApiHeader.fromJsonString(json['customHeaders'] as String)
              : (json['customHeaders'] as List).map((e) => ApiHeader.fromJson(e)).toList())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'code': code,
      'name': name,
      'description': description,
      'httpMethod': httpMethod,
      'pathPattern': pathPattern,
      'requestContentType': requestContentType,
      'responseContentType': responseContentType,
      'timeoutSeconds': timeoutSeconds,
      'cacheTtlSeconds': cacheTtlSeconds,
      'rateLimitPerMinute': rateLimitPerMinute,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'requestBodySchema': requestBodySchema,
      'requestBodyExample': requestBodyExample,
      'responseBodySchema': responseBodySchema,
      'responseBodyExample': responseBodyExample,
      'queryParameters': queryParameters?.map((e) => e.toJson()).toList(),
      'pathParameters': pathParameters?.map((e) => e.toJson()).toList(),
      'customHeaders': customHeaders?.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns the external path that partners should use (includes /integration prefix)
  String get externalPath => '/integration$pathPattern';

  ApiDefinition copyWith({
    String? id,
    String? collectionId,
    String? code,
    String? name,
    String? description,
    String? httpMethod,
    String? pathPattern,
    String? requestContentType,
    String? responseContentType,
    int? timeoutSeconds,
    int? cacheTtlSeconds,
    int? rateLimitPerMinute,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? requestBodySchema,
    String? requestBodyExample,
    String? responseBodySchema,
    String? responseBodyExample,
    List<ApiParameter>? queryParameters,
    List<ApiParameter>? pathParameters,
    List<ApiHeader>? customHeaders,
  }) {
    return ApiDefinition(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      httpMethod: httpMethod ?? this.httpMethod,
      pathPattern: pathPattern ?? this.pathPattern,
      requestContentType: requestContentType ?? this.requestContentType,
      responseContentType: responseContentType ?? this.responseContentType,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      cacheTtlSeconds: cacheTtlSeconds ?? this.cacheTtlSeconds,
      rateLimitPerMinute: rateLimitPerMinute ?? this.rateLimitPerMinute,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requestBodySchema: requestBodySchema ?? this.requestBodySchema,
      requestBodyExample: requestBodyExample ?? this.requestBodyExample,
      responseBodySchema: responseBodySchema ?? this.responseBodySchema,
      responseBodyExample: responseBodyExample ?? this.responseBodyExample,
      queryParameters: queryParameters ?? this.queryParameters,
      pathParameters: pathParameters ?? this.pathParameters,
      customHeaders: customHeaders ?? this.customHeaders,
    );
  }

  String get methodColor {
    switch (httpMethod.toUpperCase()) {
      case 'GET':
        return '#61affe'; // Blue
      case 'POST':
        return '#49cc90'; // Green
      case 'PUT':
        return '#fca130'; // Orange
      case 'PATCH':
        return '#50e3c2'; // Teal
      case 'DELETE':
        return '#f93e3e'; // Red
      default:
        return '#9012fe'; // Purple
    }
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
}

/// Represents a query or path parameter for an API endpoint
class ApiParameter {
  final String name;
  final String? type;
  final bool required;
  final String? description;
  final String? example;

  ApiParameter({
    required this.name,
    this.type,
    this.required = false,
    this.description,
    this.example,
  });

  factory ApiParameter.fromJson(Map<String, dynamic> json) {
    return ApiParameter(
      name: json['name'] as String,
      type: json['type'] as String?,
      required: json['required'] as bool? ?? false,
      description: json['description'] as String?,
      example: json['example'] as String?,
    );
  }

  static List<ApiParameter> fromJsonString(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => ApiParameter.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'required': required,
      'description': description,
      'example': example,
    };
  }
}

/// Represents a custom header for an API endpoint
class ApiHeader {
  final String name;
  final bool required;
  final String? description;
  final String? example;

  ApiHeader({
    required this.name,
    this.required = false,
    this.description,
    this.example,
  });

  factory ApiHeader.fromJson(Map<String, dynamic> json) {
    return ApiHeader(
      name: json['name'] as String,
      required: json['required'] as bool? ?? false,
      description: json['description'] as String?,
      example: json['example'] as String?,
    );
  }

  static List<ApiHeader> fromJsonString(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => ApiHeader.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'required': required,
      'description': description,
      'example': example,
    };
  }
}

enum AccessLevel {
  full,
  selective,
}

extension AccessLevelExtension on AccessLevel {
  String get value {
    switch (this) {
      case AccessLevel.full:
        return 'FULL';
      case AccessLevel.selective:
        return 'SELECTIVE';
    }
  }

  String get displayName {
    switch (this) {
      case AccessLevel.full:
        return 'Full Access';
      case AccessLevel.selective:
        return 'Selective Access';
    }
  }

  static AccessLevel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FULL':
        return AccessLevel.full;
      case 'SELECTIVE':
        return AccessLevel.selective;
      default:
        return AccessLevel.selective;
    }
  }
}

class PartnerCollectionAccess {
  final String id;
  final String partnerId;
  final String partnerName;
  final String collectionId;
  final String collectionCode;
  final String collectionName;
  final AccessLevel accessLevel;
  final int? rateLimitOverride;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnerCollectionAccess({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.collectionId,
    required this.collectionCode,
    required this.collectionName,
    required this.accessLevel,
    this.rateLimitOverride,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerCollectionAccess.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] as Map<String, dynamic>?;
    final collection = json['collection'] as Map<String, dynamic>?;

    return PartnerCollectionAccess(
      id: json['id'] as String,
      partnerId: partner?['id'] as String? ?? json['partnerId'] as String? ?? '',
      partnerName: partner?['name'] as String? ?? '',
      collectionId: collection?['id'] as String? ?? json['collectionId'] as String? ?? '',
      collectionCode: collection?['code'] as String? ?? '',
      collectionName: collection?['name'] as String? ?? '',
      accessLevel: AccessLevelExtension.fromString(json['accessLevel'] as String? ?? 'FULL'),
      rateLimitOverride: json['rateLimitOverride'] as int?,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom'] as String) : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'] as String) : null,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'collectionId': collectionId,
      'accessLevel': accessLevel.value,
      'rateLimitOverride': rateLimitOverride,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return isActive;
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (!isValid) return 'Expired';
    return 'Active';
  }
}

class PartnerApiAccess {
  final String id;
  final String partnerId;
  final String partnerName;
  final String apiDefinitionId;
  final String apiCode;
  final String apiName;
  final String httpMethod;
  final String pathPattern;
  final int? rateLimitOverride;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnerApiAccess({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.apiDefinitionId,
    required this.apiCode,
    required this.apiName,
    required this.httpMethod,
    required this.pathPattern,
    this.rateLimitOverride,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerApiAccess.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] as Map<String, dynamic>?;
    final apiDef = json['apiDefinition'] as Map<String, dynamic>?;

    return PartnerApiAccess(
      id: json['id'] as String,
      partnerId: partner?['id'] as String? ?? json['partnerId'] as String? ?? '',
      partnerName: partner?['name'] as String? ?? '',
      apiDefinitionId: apiDef?['id'] as String? ?? json['apiDefinitionId'] as String? ?? '',
      apiCode: apiDef?['code'] as String? ?? '',
      apiName: apiDef?['name'] as String? ?? '',
      httpMethod: apiDef?['httpMethod'] as String? ?? '',
      pathPattern: apiDef?['pathPattern'] as String? ?? '',
      rateLimitOverride: json['rateLimitOverride'] as int?,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom'] as String) : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'] as String) : null,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'apiDefinitionId': apiDefinitionId,
      'rateLimitOverride': rateLimitOverride,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return isActive;
  }

  /// Returns the external path that partners should use (includes /integration prefix)
  String get externalPath => '/integration$pathPattern';

  String get statusText {
    if (!isActive) return 'Inactive';
    if (!isValid) return 'Expired';
    return 'Active';
  }
}

class PartnerAccessSummary {
  final String partnerId;
  final String partnerName;
  final int collectionAccessCount;
  final int individualApiAccessCount;
  final int totalAccessibleApis;
  final List<PartnerCollectionAccess> collectionAccess;
  final List<PartnerApiAccess> apiAccess;

  PartnerAccessSummary({
    required this.partnerId,
    required this.partnerName,
    required this.collectionAccessCount,
    required this.individualApiAccessCount,
    required this.totalAccessibleApis,
    required this.collectionAccess,
    required this.apiAccess,
  });

  factory PartnerAccessSummary.fromJson(Map<String, dynamic> json) {
    return PartnerAccessSummary(
      partnerId: json['partnerId'] as String,
      partnerName: json['partnerName'] as String,
      collectionAccessCount: json['collectionAccessCount'] as int? ?? 0,
      individualApiAccessCount: json['individualApiAccessCount'] as int? ?? 0,
      totalAccessibleApis: json['totalAccessibleApis'] as int? ?? 0,
      collectionAccess: (json['collectionAccess'] as List?)
              ?.map((e) => PartnerCollectionAccess.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      apiAccess: (json['apiAccess'] as List?)
              ?.map((e) => PartnerApiAccess.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
