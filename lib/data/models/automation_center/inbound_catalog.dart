import 'dart:convert';

import 'package:equatable/equatable.dart';

enum CatalogAuthMode {
  none,
  bearer;

  static CatalogAuthMode fromJson(Object? value) {
    final raw = value?.toString().toUpperCase();
    return switch (raw) {
      'NONE' => CatalogAuthMode.none,
      'BEARER' => CatalogAuthMode.bearer,
      _ => throw FormatException('Unsupported catalog authMode: $value'),
    };
  }

  bool get requiresAuthorization => this != CatalogAuthMode.none;
}

class CatalogRequestExample extends Equatable {
  const CatalogRequestExample({
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.headers = const {},
    this.body,
    this.notes,
  });

  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final Object? body;
  final String? notes;

  bool get hasJsonBody => body != null;

  factory CatalogRequestExample.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CatalogRequestExample();
    return CatalogRequestExample(
      pathParameters: _stringMap(json['pathParameters']),
      queryParameters: _stringMap(json['queryParameters']),
      headers: _stringMap(json['headers']),
      body: json['body'],
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        pathParameters,
        queryParameters,
        headers,
        body,
        notes,
      ];
}

class CatalogResponseExample extends Equatable {
  const CatalogResponseExample({
    this.status,
    this.description,
    this.body,
  });

  final int? status;
  final String? description;
  final Object? body;

  factory CatalogResponseExample.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CatalogResponseExample();
    return CatalogResponseExample(
      status: json['status'] as int?,
      description: json['description'] as String?,
      body: json['body'],
    );
  }

  String get displayText {
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    if (status != null) return status.toString();
    return '';
  }

  @override
  List<Object?> get props => [status, description, body];
}

class InboundCatalogEndpoint extends Equatable {
  const InboundCatalogEndpoint({
    required this.id,
    required this.title,
    required this.description,
    required this.method,
    required this.path,
    required this.order,
    required this.authMode,
    required this.example,
    required this.expectedResult,
  });

  final String id;
  final String title;
  final String description;
  final String method;
  final String path;
  final int order;
  final CatalogAuthMode authMode;
  final CatalogRequestExample example;
  final CatalogResponseExample expectedResult;

  bool get requiresAuthorization => authMode.requiresAuthorization;

  factory InboundCatalogEndpoint.fromJson(Map<String, dynamic> json) {
    return InboundCatalogEndpoint(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      method: json['method'] as String,
      path: json['path'] as String,
      order: json['order'] as int? ?? 0,
      authMode: CatalogAuthMode.fromJson(json['authMode']),
      example: CatalogRequestExample.fromJson(
        json['example'] as Map<String, dynamic>?,
      ),
      expectedResult: CatalogResponseExample.fromJson(
        json['expectedResult'] as Map<String, dynamic>?,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        method,
        path,
        order,
        authMode,
        example,
        expectedResult,
      ];
}

class InboundCatalogCategory extends Equatable {
  const InboundCatalogCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.endpoints,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final List<InboundCatalogEndpoint> endpoints;

  factory InboundCatalogCategory.fromJson(Map<String, dynamic> json) {
    final endpointsJson = json['endpoints'] as List<dynamic>? ?? const [];
    return InboundCatalogCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      endpoints: endpointsJson
          .map((e) => InboundCatalogEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [id, title, description, order, endpoints];
}

class InboundCatalog extends Equatable {
  const InboundCatalog({
    required this.schemaVersion,
    required this.generatedAt,
    required this.categories,
  });

  static const supportedSchemaVersion = 1;

  final int schemaVersion;
  final String? generatedAt;
  final List<InboundCatalogCategory> categories;

  factory InboundCatalog.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int?;
    if (schemaVersion == null) {
      throw const FormatException('Catalog response missing schemaVersion');
    }
    if (schemaVersion != supportedSchemaVersion) {
      throw FormatException(
        'Unsupported inbound catalog schemaVersion $schemaVersion '
        '(supported: $supportedSchemaVersion)',
      );
    }
    final categoriesJson = json['categories'] as List<dynamic>? ?? const [];
    return InboundCatalog(
      schemaVersion: schemaVersion,
      generatedAt: json['generatedAt'] as String?,
      categories: categoriesJson
          .map((e) => InboundCatalogCategory.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [schemaVersion, generatedAt, categories];
}

Map<String, String> _stringMap(Object? raw) {
  if (raw is! Map) return const {};
  return raw.map((key, value) => MapEntry('$key', value?.toString() ?? ''));
}

/// Builds an example relative URL from backend path + structured example.
String buildCatalogExampleUrl(InboundCatalogEndpoint endpoint) {
  var path = endpoint.path;
  endpoint.example.pathParameters.forEach((key, value) {
    path = path.replaceAll('{$key}', value);
  });
  if (endpoint.example.queryParameters.isEmpty) return path;
  final query = endpoint.example.queryParameters.entries
      .map(
        (e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      )
      .join('&');
  return '$path?$query';
}

String formatCatalogRequestExample(InboundCatalogEndpoint endpoint) {
  final example = endpoint.example;
  if (example.hasJsonBody) {
    return const JsonEncoder.withIndent('  ').convert(example.body);
  }
  if (example.notes != null && example.notes!.trim().isNotEmpty) {
    return example.notes!;
  }
  return 'No body.';
}

String buildCatalogCurl(InboundCatalogEndpoint endpoint) {
  final resolvedPath = buildCatalogExampleUrl(endpoint);
  final authorization = endpoint.requiresAuthorization
      ? " -H 'Authorization: Bearer {{token}}'"
      : '';
  final body = endpoint.example.hasJsonBody
      ? " -H 'Content-Type: application/json' --data '${jsonEncode(endpoint.example.body)}'"
      : '';
  return "curl -X ${endpoint.method} '{{baseUrl}}$resolvedPath'$authorization$body";
}
