import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

/// Hand-curated from backend/docs/system-role-endpoint-audit.md.
/// Never add an endpoint here unless that audit classifies it extended-to-system.
///
/// [request] holds either a real, ready-to-send JSON body (for endpoints that
/// take one) or a plain-English note for GET/no-body endpoints. Any `{token}`
/// style placeholder inside [path] is resolved to a realistic, already-valid
/// sample value both in the on-screen docs and in the downloadable Postman
/// collection (see [resolveTestPath]) so a partner can hit "Send" without
/// editing anything first.
class InboundEndpoint {
  const InboundEndpoint({
    required this.method,
    required this.path,
    required this.description,
    required this.request,
    required this.response,
    this.requiresAuthorization = true,
  });

  final String method;
  final String path;
  final String description;
  final String request;
  final String response;
  final bool requiresAuthorization;

  /// True when [request] is an actual JSON body to send, not prose.
  bool get hasJsonBody {
    final trimmed = request.trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }
}

class InboundCategory {
  const InboundCategory(this.name, this.description, this.icon, this.endpoints);

  final String name;
  final String description;
  final IconData icon;
  final List<InboundEndpoint> endpoints;
}

/// Realistic, already-valid sample values substituted into `{placeholder}`
/// tokens in an endpoint's path - the same GTIN/GLN/EPC values used elsewhere
/// in this codebase's own tests and sample payloads, not made up on the spot.
const _testValues = <String, String>{
  'gtinCode': '00614141123452',
  'glnCode': '0614141123452',
  'epc': 'https://id.gs1.org/01/00614141073467/21/SERIAL1',
  'parentEPC': 'https://id.gs1.org/01/00614141073467/21/PARENT01',
};

/// Resolves every `{placeholder}` in [rawPath] to a real sample value.
/// EPC-style values are full URIs, so they're percent-encoded when they sit
/// inside a query string (`?epc={epc}`) but left bare in a path segment.
String resolveTestPath(String rawPath) {
  var resolved = rawPath;
  for (final entry in _testValues.entries) {
    final token = '{${entry.key}}';
    if (!resolved.contains(token)) continue;
    final inQueryString = resolved.contains('=$token');
    final value = inQueryString
        ? Uri.encodeComponent(entry.value)
        : entry.value;
    resolved = resolved.replaceAll(token, value);
  }
  return resolved;
}

const inboundApiCategories = <InboundCategory>[
  InboundCategory(
    'Authentication',
    'Exchange B2B Service credentials for a JWT access token.',
    Icons.login_outlined,
    [
      InboundEndpoint(
        method: 'POST',
        path: '/auth/login',
        description: 'Authenticate with a username or email and password.',
        request:
            '{"username":"your-b2b-service-username","password":"your-password"}',
        response:
            '200 JWT response containing the access token and account details; 400 validation; 401 invalid or unavailable account.',
        requiresAuthorization: false,
      ),
    ],
  ),
  InboundCategory(
    'Master Data',
    'GTIN and GLN records, validation and lookup.',
    Icons.inventory_2_outlined,
    [
      InboundEndpoint(
        method: 'GET',
        path: '/master-data/gtins?size=20',
        description: 'List paginated GTIN master data.',
        request: 'No body. Optional page, size and sort query parameters.',
        response: '200 PageResponse<GTINDTO>; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/master-data/gtins/code/{gtinCode}',
        description: 'Look up a GTIN by its code.',
        request:
            'No body. {gtinCode} is a sample 14-digit GTIN already filled in below.',
        response: '200 GTINDTO; 404 not found; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/master-data/glns/code/{glnCode}',
        description: 'Look up a location by GLN.',
        request:
            'No body. {glnCode} is a sample 13-digit GLN already filled in below.',
        response: '200 GLNDTO; 404 not found; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/master-data/glns/validate?glnCode=0614141123452',
        description: 'Validate a GLN check digit and structure.',
        request: 'No body; glnCode query parameter is required.',
        response: '200 {valid, glnCode}; 400 invalid input; 403 forbidden.',
      ),
    ],
  ),
  InboundCategory(
    'Serialization',
    'Convert, validate and resolve EPCIS payloads and identifiers.',
    Icons.code_outlined,
    [
      InboundEndpoint(
        method: 'POST',
        path: '/events/serialization/validate/json',
        description: 'Validate an EPCIS JSON-LD document.',
        request:
            '{"@context":["https://ref.gs1.org/standards/epcis/epcis-context.jsonld"],"type":"EPCISDocument","schemaVersion":"2.0","epcisBody":{"eventList":[{"type":"ObjectEvent","eventTime":"2026-01-01T00:00:00Z","eventTimeZoneOffset":"+00:00","action":"OBSERVE","epcList":["https://id.gs1.org/01/00614141073467/21/SERIAL1"],"bizStep":"urn:epcglobal:cbv:bizstep:commissioning","disposition":"urn:epcglobal:cbv:disp:active"}]}}',
        response:
            '200 validation result map; 400 malformed JSON; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'POST',
        path: '/events/serialization/jsonld',
        description: 'Serialize an EPCIS document as JSON-LD.',
        request:
            '{"schemaVersion":"2.0","epcisBody":{"eventList":[{"type":"ObjectEvent","eventTime":"2026-01-01T00:00:00Z","eventTimeZoneOffset":"+00:00","action":"OBSERVE","epcList":["https://id.gs1.org/01/00614141073467/21/SERIAL1"],"bizStep":"urn:epcglobal:cbv:bizstep:commissioning","disposition":"urn:epcglobal:cbv:disp:active"}]}}',
        response: '200 JSON-LD document; 400 validation error; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/pharmaceutical/identifiers/resolve?epc={epc}',
        description:
            'Resolve an SGTIN or SSCC EPC to product/container information.',
        request:
            'No body. {epc} is a sample EPC URI already URL-encoded below.',
        response: '200 unified identifier DTO; 404 unresolved; 403 forbidden.',
      ),
    ],
  ),
  InboundCategory(
    'Operations',
    'Create and inspect supply-chain workflows.',
    Icons.local_shipping_outlined,
    [
      InboundEndpoint(
        method: 'GET',
        path: '/operations/shipping?page=0&size=20',
        description: 'List shipping operations.',
        request: 'No body. Pagination query parameters are optional.',
        response: '200 ShippingPageResponseDTO; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'POST',
        path: '/operations/shipping',
        description: 'Create a shipping operation.',
        request:
            '{"epcs":["https://id.gs1.org/01/00614141073467/21/SERIAL1"],"sourceGLN":"0614141000058","destinationGLN":"0614141123452","eventTime":"2026-01-01T09:00:00Z","eventTimeZoneOffset":"+00:00","purchaseOrderNumber":"PO-1000001","carrier":"Sample Freight Co","trackingNumber":"TRACK-0001","comments":"Sample shipment created from the Inbound API catalog."}',
        response: '201 ShippingResponseDTO; 400 validation; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/operations/receiving?page=0&size=20',
        description: 'List receiving operations.',
        request: 'No body. Pagination query parameters are optional.',
        response: '200 ReceivingPageResponseDTO; 403 forbidden.',
      ),
    ],
  ),
  InboundCategory(
    'Traceability',
    'Read product hierarchy and journey information.',
    Icons.account_tree_outlined,
    [
      InboundEndpoint(
        method: 'GET',
        path: '/events/aggregation/children?parentEPC={parentEPC}',
        description: 'Load children of an aggregation container.',
        request:
            'No body. {parentEPC} is a sample container EPC already URL-encoded below.',
        response: '200 HierarchyPageDTO; 400 invalid EPC; 403 forbidden.',
      ),
      InboundEndpoint(
        method: 'GET',
        path: '/product-journey/epc?epc={epc}',
        description: 'Get the chronological journey for an EPC.',
        request:
            'No body. {epc} is a sample EPC URI already URL-encoded below.',
        response: '200 product journey DTO; 404 not found; 403 forbidden.',
      ),
    ],
  ),
];

/// Builds a ready-to-import Postman Collection v2.1 for a single category.
/// `{{baseUrl}}` defaults to this app's configured API base URL and
/// `{{token}}` is left for the tester to paste in - everything else
/// (paths, query params, request bodies) is already filled with realistic
/// sample data so requests can be sent with no edits.
Map<String, dynamic> buildPostmanCollection(InboundCategory category) {
  final baseUrl = getIt<AppConfig>().apiBaseUrl;
  return {
    'info': {
      'name': 'TraqTrace - ${category.name} (B2B Service sandbox)',
      'description':
          '${category.description}\n\nGenerated from the TraqTrace Inbound API catalog. '
          'Every request already has sample test data filled in - set the '
          '{{token}} collection variable to a B2B Service user JWT (see the "How '
          'to authenticate" note in the Inbound tab) and press Send.',
      'schema':
          'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    },
    'variable': [
      {'key': 'baseUrl', 'value': baseUrl, 'type': 'string'},
      {
        'key': 'token',
        'value': 'PASTE_YOUR_B2B_SERVICE_USER_JWT_HERE',
        'type': 'string',
      },
    ],
    'item': [
      for (final endpoint in category.endpoints)
        {
          'name':
              '${endpoint.method} ${endpoint.path} - ${endpoint.description}',
          'request': {
            'method': endpoint.method,
            'header': [
              if (endpoint.requiresAuthorization)
                {'key': 'Authorization', 'value': 'Bearer {{token}}'},
              if (endpoint.hasJsonBody)
                {'key': 'Content-Type', 'value': 'application/json'},
            ],
            'url': {'raw': '{{baseUrl}}${resolveTestPath(endpoint.path)}'},
            if (endpoint.hasJsonBody)
              'body': {
                'mode': 'raw',
                'raw': endpoint.request,
                'options': {
                  'raw': {'language': 'json'},
                },
              },
            'description': endpoint.description,
          },
          'response': [],
        },
    ],
  };
}

class InboundApiCatalog extends StatefulWidget {
  const InboundApiCatalog({super.key});

  @override
  State<InboundApiCatalog> createState() => _InboundApiCatalogState();
}

class _InboundApiCatalogState extends State<InboundApiCatalog> {
  InboundCategory? _selected;

  Future<void> _copy(BuildContext context, InboundEndpoint endpoint) async {
    final resolvedPath = resolveTestPath(endpoint.path);
    final body = endpoint.hasJsonBody
        ? " -H 'Content-Type: application/json' --data '${endpoint.request}'"
        : '';
    final authorization = endpoint.requiresAuthorization
        ? " -H 'Authorization: Bearer {{token}}'"
        : '';
    await Clipboard.setData(
      ClipboardData(
        text:
            "curl -X ${endpoint.method} '{{baseUrl}}$resolvedPath'$authorization$body",
      ),
    );
    if (context.mounted) context.showSuccess('curl command copied');
  }

  void _downloadCollection(BuildContext context, InboundCategory category) {
    final collection = buildPostmanCollection(category);
    final slug = category.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    web_download.downloadBytes(
      bytes: utf8.encode(
        const JsonEncoder.withIndent('  ').convert(collection),
      ),
      filename: 'traqtrace-$slug-collection.json',
      mimeType: 'application/json',
    );
    context.showSuccess(
      '${category.name} collection downloaded with sample test data - '
      'import it into Postman and set the token variable.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('API Collections', style: context.text.h3),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Select a collection to view B2B-Service-accessible endpoints, copy authenticated '
          'requests, or download the whole group as a Postman collection pre-filled '
          'with sample test data.',
          style: context.text.body.copyWith(color: context.colors.textMuted),
        ),
        const SizedBox(height: TraqSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 165,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: inboundApiCategories.length,
          itemBuilder: (context, index) {
            final category = inboundApiCategories[index];
            return Card(
              color: selected == category
                  ? context.colors.primary
                  : null,
              child: InkWell(
                onTap: () => setState(() => _selected = category),
                child: Padding(
                  padding: const EdgeInsets.all(TraqSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(category.icon, color: selected == category
                              ? Colors.white:context.colors.primary),
                          const Spacer(),
                          DecoratedBox(

                              decoration:BoxDecoration(
                                color: selected == category
                                    ? Colors.white:context.colors.primary,
                                shape: BoxShape.circle
                              ),child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text('${category.endpoints.length}',style: TextStyle(
                                color: selected == category
                                    ? context.colors.primary:Colors.white
                              ),),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: TraqSpacing.sm),
                      Text(category.name, style: context.text.h3.copyWith(color: selected == category
                      ? Colors.white:context.colors.primary),),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                                color: selected == category
                                ? Colors.white:context.colors.primary
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              _downloadCollection(context, category),
                          icon:  Icon(Icons.download, size: 16, color: selected == category
                              ? Colors.white:context.colors.primary),
                          label:  Text('Download collection',style: TextStyle(
                                color: selected == category
                                  ? Colors.white:context.colors.primary
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (selected != null) ...[
          const SizedBox(height: TraqSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${selected.name} endpoints',
                  style: context.text.h3,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _downloadCollection(context, selected),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download collection'),
              ),
            ],
          ),
          ...selected.endpoints.map(
            (endpoint) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                '${endpoint.method}  ${resolveTestPath(endpoint.path)}',
              ),
              subtitle: Text(endpoint.description),
              childrenPadding: const EdgeInsets.fromLTRB(
                TraqSpacing.md,
                0,
                TraqSpacing.md,
                TraqSpacing.md,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText(
                    'Request\n${endpoint.request}\n\nResponse\n${endpoint.response}',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _copy(context, endpoint),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy as curl'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
