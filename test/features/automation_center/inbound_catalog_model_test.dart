import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/automation_center/inbound_catalog.dart';

void main() {
  group('InboundCatalog parsing', () {
    final sample = {
      'schemaVersion': 1,
      'generatedAt': '2026-08-13T00:00:00Z',
      'categories': [
        {
          'id': 'operations',
          'title': 'Operations',
          'description': 'Ops',
          'order': 40,
          'endpoints': [
            {
              'id': 'operations.shipping.list',
              'title': 'List Shipping Operations',
              'description': 'List shipping operations.',
              'method': 'GET',
              'path': '/operations/shipping',
              'order': 10,
              'authMode': 'BEARER',
              'example': {
                'pathParameters': {},
                'queryParameters': {'page': '0', 'size': '20'},
                'headers': {},
                'body': null,
                'notes': 'No body. Pagination query parameters are optional.',
              },
              'expectedResult': {
                'status': 200,
                'description': '200 ShippingPageResponseDTO; 403 forbidden.',
                'body': null,
              },
            },
            {
              'id': 'operations.shipping.create',
              'title': 'Create Shipping Operation',
              'description': 'Create a shipping operation.',
              'method': 'POST',
              'path': '/operations/shipping',
              'order': 20,
              'authMode': 'BEARER',
              'example': {
                'pathParameters': {},
                'queryParameters': {},
                'headers': {},
                'body': {
                  'epcs': ['https://id.gs1.org/01/00614141073467/21/SERIAL1'],
                },
              },
              'expectedResult': {
                'status': 201,
                'description': '201 ShippingResponseDTO',
              },
            },
          ],
        },
        {
          'id': 'authentication',
          'title': 'Authentication',
          'description': 'Auth',
          'order': 10,
          'endpoints': [
            {
              'id': 'auth.login',
              'title': 'Login',
              'description': 'Authenticate',
              'method': 'POST',
              'path': '/auth/login',
              'order': 10,
              'authMode': 'NONE',
              'example': {
                'body': {'username': 'u', 'password': 'p'},
              },
              'expectedResult': {'status': 200, 'description': 'JWT'},
            },
          ],
        },
      ],
    };

    test('parses schema version 1 catalog', () {
      final catalog = InboundCatalog.fromJson(sample);
      expect(catalog.schemaVersion, 1);
      expect(catalog.categories, hasLength(2));
      expect(catalog.categories.first.id, 'operations');
    });

    test('decodes NONE and BEARER auth modes', () {
      final catalog = InboundCatalog.fromJson(sample);
      final bearer = catalog.categories.first.endpoints.first;
      final none = catalog.categories.last.endpoints.first;
      expect(bearer.authMode, CatalogAuthMode.bearer);
      expect(bearer.requiresAuthorization, isTrue);
      expect(none.authMode, CatalogAuthMode.none);
      expect(none.requiresAuthorization, isFalse);
    });

    test('rejects unsupported schema version', () {
      expect(
        () => InboundCatalog.fromJson({...sample, 'schemaVersion': 99}),
        throwsA(isA<FormatException>()),
      );
    });

    test('buildCatalogExampleUrl keeps query separate from path', () {
      final endpoint = InboundCatalog.fromJson(sample).categories.first.endpoints.first;
      expect(endpoint.path, '/operations/shipping');
      expect(
        buildCatalogExampleUrl(endpoint),
        '/operations/shipping?page=0&size=20',
      );
    });

    test('buildCatalogCurl uses bearer and json body', () {
      final create =
          InboundCatalog.fromJson(sample).categories.first.endpoints[1];
      final curl = buildCatalogCurl(create);
      expect(curl, contains("curl -X POST '{{baseUrl}}/operations/shipping'"));
      expect(curl, contains("Authorization: Bearer {{token}}"));
      expect(curl, contains("Content-Type: application/json"));
      expect(curl, contains('--data'));
    });

    test('buildCatalogCurl encodes query EPC values', () {
      final endpoint = InboundCatalogEndpoint(
        id: 'serialization.pharma.resolve',
        title: 'Resolve',
        description: 'Resolve',
        method: 'GET',
        path: '/pharmaceutical/identifiers/resolve',
        order: 30,
        authMode: CatalogAuthMode.bearer,
        example: const CatalogRequestExample(
          queryParameters: {
            'epc': 'https://id.gs1.org/01/00614141073467/21/SERIAL1',
          },
        ),
        expectedResult: const CatalogResponseExample(status: 200),
      );
      final curl = buildCatalogCurl(endpoint);
      expect(
        curl,
        contains(
          'epc=https%3A%2F%2Fid.gs1.org%2F01%2F00614141073467%2F21%2FSERIAL1',
        ),
      );
    });
  });
}
