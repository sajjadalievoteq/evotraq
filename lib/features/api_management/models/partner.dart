/// Partner model for B2B API integration
/// Supports both inbound (partner calls us) and outbound (we call partner) integrations.
class Partner {
  final String id;
  final String partnerCode;
  final String companyName;
  final String? gln;
  final PartnerType partnerType;
  final DataFormat preferredDataFormat;
  final String? webhookUrl;
  final String? contactEmail;
  final String? contactName;
  final String? contactPhone;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Sync configuration
  final SyncDirection syncDirection;
  final bool syncEnabled;
  final int syncIntervalMinutes;
  final DateTime? lastSyncAt;
  final String? lastSyncStatus;
  final String? lastSyncError;

  // Outbound connection configuration
  final String? outboundApiUrl;
  final String? outboundEventsEndpoint;
  final String? outboundMasterdataEndpoint;
  final OutboundAuthType? outboundAuthType;
  final String? outboundApiKeyHeader;
  final bool outboundApiKeyConfigured;
  final String? outboundClientId;
  final bool outboundClientSecretConfigured;
  final String? outboundTokenUrl;
  final String? outboundScopes;
  final String? outboundUsername;
  final bool outboundPasswordConfigured;
  final int outboundTimeoutSeconds;
  final int outboundRetryCount;

  // Data filtering
  final String? syncEventTypes;
  final String? syncLocationFilter;
  final String? syncProductFilter;
  final DateTime? syncFromDate;

  Partner({
    required this.id,
    required this.partnerCode,
    required this.companyName,
    this.gln,
    required this.partnerType,
    required this.preferredDataFormat,
    this.webhookUrl,
    this.contactEmail,
    this.contactName,
    this.contactPhone,
    required this.active,
    required this.createdAt,
    this.updatedAt,
    // Sync configuration
    this.syncDirection = SyncDirection.inbound,
    this.syncEnabled = false,
    this.syncIntervalMinutes = 60,
    this.lastSyncAt,
    this.lastSyncStatus,
    this.lastSyncError,
    // Outbound connection
    this.outboundApiUrl,
    this.outboundEventsEndpoint,
    this.outboundMasterdataEndpoint,
    this.outboundAuthType,
    this.outboundApiKeyHeader,
    this.outboundApiKeyConfigured = false,
    this.outboundClientId,
    this.outboundClientSecretConfigured = false,
    this.outboundTokenUrl,
    this.outboundScopes,
    this.outboundUsername,
    this.outboundPasswordConfigured = false,
    this.outboundTimeoutSeconds = 30,
    this.outboundRetryCount = 3,
    // Data filtering
    this.syncEventTypes,
    this.syncLocationFilter,
    this.syncProductFilter,
    this.syncFromDate,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? '',
      partnerCode: json['partnerCode'] ?? '',
      companyName: json['companyName'] ?? '',
      gln: json['gln'],
      partnerType: PartnerType.fromString(json['partnerType'] ?? 'OTHER'),
      preferredDataFormat: DataFormat.fromString(json['preferredDataFormat'] ?? 'EPCIS_JSON'),
      webhookUrl: json['webhookUrl'],
      contactEmail: json['contactEmail'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      active: json['active'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      // Sync configuration
      syncDirection: SyncDirection.fromString(json['syncDirection'] ?? 'INBOUND'),
      syncEnabled: json['syncEnabled'] ?? false,
      syncIntervalMinutes: json['syncIntervalMinutes'] ?? 60,
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt']) 
          : null,
      lastSyncStatus: json['lastSyncStatus'],
      lastSyncError: json['lastSyncError'],
      // Outbound connection
      outboundApiUrl: json['outboundApiUrl'],
      outboundEventsEndpoint: json['outboundEventsEndpoint'],
      outboundMasterdataEndpoint: json['outboundMasterdataEndpoint'],
      outboundAuthType: json['outboundAuthType'] != null 
          ? OutboundAuthType.fromString(json['outboundAuthType']) 
          : null,
      outboundApiKeyHeader: json['outboundApiKeyHeader'],
      outboundApiKeyConfigured: json['outboundApiKeyConfigured'] ?? false,
      outboundClientId: json['outboundClientId'],
      outboundClientSecretConfigured: json['outboundClientSecretConfigured'] ?? false,
      outboundTokenUrl: json['outboundTokenUrl'],
      outboundScopes: json['outboundScopes'],
      outboundUsername: json['outboundUsername'],
      outboundPasswordConfigured: json['outboundPasswordConfigured'] ?? false,
      outboundTimeoutSeconds: json['outboundTimeoutSeconds'] ?? 30,
      outboundRetryCount: json['outboundRetryCount'] ?? 3,
      // Data filtering
      syncEventTypes: json['syncEventTypes'],
      syncLocationFilter: json['syncLocationFilter'],
      syncProductFilter: json['syncProductFilter'],
      syncFromDate: json['syncFromDate'] != null 
          ? DateTime.parse(json['syncFromDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerCode': partnerCode,
      'companyName': companyName,
      'gln': gln,
      'partnerType': partnerType.value,
      'preferredDataFormat': preferredDataFormat.value,
      'webhookUrl': webhookUrl,
      'contactEmail': contactEmail,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'active': active,
      // Sync configuration
      'syncDirection': syncDirection.value,
      'syncEnabled': syncEnabled,
      'syncIntervalMinutes': syncIntervalMinutes,
      // Outbound connection
      'outboundApiUrl': outboundApiUrl,
      'outboundEventsEndpoint': outboundEventsEndpoint,
      'outboundMasterdataEndpoint': outboundMasterdataEndpoint,
      'outboundAuthType': outboundAuthType?.value,
      'outboundApiKeyHeader': outboundApiKeyHeader,
      'outboundClientId': outboundClientId,
      'outboundTokenUrl': outboundTokenUrl,
      'outboundScopes': outboundScopes,
      'outboundUsername': outboundUsername,
      'outboundTimeoutSeconds': outboundTimeoutSeconds,
      'outboundRetryCount': outboundRetryCount,
      // Data filtering
      'syncEventTypes': syncEventTypes,
      'syncLocationFilter': syncLocationFilter,
      'syncProductFilter': syncProductFilter,
      'syncFromDate': syncFromDate?.toIso8601String(),
    };
  }

  /// Whether this partner has outbound integration configured
  bool get hasOutboundIntegration => 
      syncDirection == SyncDirection.outbound || 
      syncDirection == SyncDirection.bidirectional;

  /// Whether this partner has inbound integration configured
  bool get hasInboundIntegration => 
      syncDirection == SyncDirection.inbound || 
      syncDirection == SyncDirection.bidirectional;

  /// Get sync status display text
  String get syncStatusDisplay {
    if (!syncEnabled) return 'Disabled';
    if (lastSyncStatus == null) return 'Never synced';
    return lastSyncStatus!;
  }

  Partner copyWith({
    String? id,
    String? partnerCode,
    String? companyName,
    String? gln,
    PartnerType? partnerType,
    DataFormat? preferredDataFormat,
    String? webhookUrl,
    String? contactEmail,
    String? contactName,
    String? contactPhone,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Sync configuration
    SyncDirection? syncDirection,
    bool? syncEnabled,
    int? syncIntervalMinutes,
    DateTime? lastSyncAt,
    String? lastSyncStatus,
    String? lastSyncError,
    // Outbound connection
    String? outboundApiUrl,
    String? outboundEventsEndpoint,
    String? outboundMasterdataEndpoint,
    OutboundAuthType? outboundAuthType,
    String? outboundApiKeyHeader,
    bool? outboundApiKeyConfigured,
    String? outboundClientId,
    bool? outboundClientSecretConfigured,
    String? outboundTokenUrl,
    String? outboundScopes,
    String? outboundUsername,
    bool? outboundPasswordConfigured,
    int? outboundTimeoutSeconds,
    int? outboundRetryCount,
    // Data filtering
    String? syncEventTypes,
    String? syncLocationFilter,
    String? syncProductFilter,
    DateTime? syncFromDate,
  }) {
    return Partner(
      id: id ?? this.id,
      partnerCode: partnerCode ?? this.partnerCode,
      companyName: companyName ?? this.companyName,
      gln: gln ?? this.gln,
      partnerType: partnerType ?? this.partnerType,
      preferredDataFormat: preferredDataFormat ?? this.preferredDataFormat,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Sync configuration
      syncDirection: syncDirection ?? this.syncDirection,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      // Outbound connection
      outboundApiUrl: outboundApiUrl ?? this.outboundApiUrl,
      outboundEventsEndpoint: outboundEventsEndpoint ?? this.outboundEventsEndpoint,
      outboundMasterdataEndpoint: outboundMasterdataEndpoint ?? this.outboundMasterdataEndpoint,
      outboundAuthType: outboundAuthType ?? this.outboundAuthType,
      outboundApiKeyHeader: outboundApiKeyHeader ?? this.outboundApiKeyHeader,
      outboundApiKeyConfigured: outboundApiKeyConfigured ?? this.outboundApiKeyConfigured,
      outboundClientId: outboundClientId ?? this.outboundClientId,
      outboundClientSecretConfigured: outboundClientSecretConfigured ?? this.outboundClientSecretConfigured,
      outboundTokenUrl: outboundTokenUrl ?? this.outboundTokenUrl,
      outboundScopes: outboundScopes ?? this.outboundScopes,
      outboundUsername: outboundUsername ?? this.outboundUsername,
      outboundPasswordConfigured: outboundPasswordConfigured ?? this.outboundPasswordConfigured,
      outboundTimeoutSeconds: outboundTimeoutSeconds ?? this.outboundTimeoutSeconds,
      outboundRetryCount: outboundRetryCount ?? this.outboundRetryCount,
      // Data filtering
      syncEventTypes: syncEventTypes ?? this.syncEventTypes,
      syncLocationFilter: syncLocationFilter ?? this.syncLocationFilter,
      syncProductFilter: syncProductFilter ?? this.syncProductFilter,
      syncFromDate: syncFromDate ?? this.syncFromDate,
    );
  }
}

/// Direction of data synchronization with the partner
enum SyncDirection {
  /// Partner calls our APIs to send/receive data
  inbound('INBOUND', 'Inbound', 'Partner calls us'),
  /// We call partner\'s APIs to send/receive data
  outbound('OUTBOUND', 'Outbound', 'We call partner'),
  /// Both directions
  bidirectional('BIDIRECTIONAL', 'Bidirectional', 'Both ways');

  final String value;
  final String displayName;
  final String description;
  const SyncDirection(this.value, this.displayName, this.description);

  static SyncDirection fromString(String value) {
    return SyncDirection.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncDirection.inbound,
    );
  }
}

/// Authentication type for outbound connections (when we call partner's APIs)
enum OutboundAuthType {
  none('NONE', 'None', 'No authentication'),
  apiKey('API_KEY', 'API Key', 'API key in header'),
  basic('BASIC', 'Basic Auth', 'Username and password'),
  oauth2ClientCredentials('OAUTH2_CLIENT_CREDENTIALS', 'OAuth2 Client Credentials', 'OAuth2 client credentials flow'),
  oauth2Custom('OAUTH2_CUSTOM', 'OAuth2 Custom', 'Custom OAuth2 token endpoint'),
  bearerToken('BEARER_TOKEN', 'Bearer Token', 'Static bearer token'),
  mtls('MTLS', 'Mutual TLS', 'Certificate-based authentication');

  final String value;
  final String displayName;
  final String description;
  const OutboundAuthType(this.value, this.displayName, this.description);

  static OutboundAuthType fromString(String value) {
    return OutboundAuthType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutboundAuthType.none,
    );
  }
}

enum PartnerType {
  manufacturer('MANUFACTURER', 'Manufacturer'),
  distributor('DISTRIBUTOR', 'Distributor'),
  retailer('RETAILER', 'Retailer'),
  logisticsProvider('LOGISTICS_PROVIDER', 'Logistics Provider'),
  regulatoryAuthority('REGULATORY_AUTHORITY', 'Regulatory Authority'),
  solutionProvider('SOLUTION_PROVIDER', 'Solution Provider'),
  other('OTHER', 'Other');

  final String value;
  final String displayName;
  const PartnerType(this.value, this.displayName);

  static PartnerType fromString(String value) {
    return PartnerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PartnerType.other,
    );
  }
}

enum DataFormat {
  epcisJson('EPCIS_JSON', 'EPCIS JSON'),
  epcisXml('EPCIS_XML', 'EPCIS XML'),
  epcisLinkedData('EPCIS_LINKED_DATA', 'EPCIS Linked Data'),
  customJson('CUSTOM_JSON', 'Custom JSON'),
  customXml('CUSTOM_XML', 'Custom XML'),
  gs1Edi('GS1_EDI', 'GS1 EDI');

  final String value;
  final String displayName;
  const DataFormat(this.value, this.displayName);

  static DataFormat fromString(String value) {
    return DataFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DataFormat.epcisJson,
    );
  }
}
