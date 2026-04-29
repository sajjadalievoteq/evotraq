/// Enumeration representing the industry mode of the system.
enum IndustryMode {
  pharmaceutical('Pharmaceutical', 'Pharma track & trace for drugs and medical devices'),
  tobacco('Tobacco', 'Tobacco track & trace with tax stamp and health warning compliance');

  final String displayName;
  final String description;

  const IndustryMode(this.displayName, this.description);

  /// Parse from string (case-insensitive).
  static IndustryMode fromString(String? value) {
    if (value == null || value.isEmpty) {
      return IndustryMode.pharmaceutical; // Default
    }
    final normalized = value.toUpperCase().trim();
    return IndustryMode.values.firstWhere(
      (mode) => mode.name.toUpperCase() == normalized,
      orElse: () => IndustryMode.pharmaceutical,
    );
  }

  /// Convert to API value (uppercase).
  String toApiValue() => name.toUpperCase();
}

/// Model representing system settings.
class SystemSettings {
  final IndustryMode industryMode;
  final String systemName;
  final String systemVersion;
  final String defaultTimezone;
  final String dateFormat;
  final String dateTimeFormat;

  const SystemSettings({
    required this.industryMode,
    required this.systemName,
    required this.systemVersion,
    required this.defaultTimezone,
    required this.dateFormat,
    required this.dateTimeFormat,
  });

  /// Default settings.
  factory SystemSettings.defaults() {
    return const SystemSettings(
      industryMode: IndustryMode.pharmaceutical,
      systemName: 'TraqTrace',
      systemVersion: '1.0.0',
      defaultTimezone: 'UTC',
      dateFormat: 'yyyy-MM-dd',
      dateTimeFormat: 'yyyy-MM-dd HH:mm:ss',
    );
  }

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      industryMode: IndustryMode.fromString(json['industryMode']),
      systemName: json['systemName'] ?? 'TraqTrace',
      systemVersion: json['systemVersion'] ?? '1.0.0',
      defaultTimezone: json['defaultTimezone'] ?? 'UTC',
      dateFormat: json['dateFormat'] ?? 'yyyy-MM-dd',
      dateTimeFormat: json['dateTimeFormat'] ?? 'yyyy-MM-dd HH:mm:ss',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'industryMode': industryMode.toApiValue(),
      'systemName': systemName,
      'systemVersion': systemVersion,
      'defaultTimezone': defaultTimezone,
      'dateFormat': dateFormat,
      'dateTimeFormat': dateTimeFormat,
    };
  }

  /// Convenience getters
  bool get isPharmaceuticalMode => industryMode == IndustryMode.pharmaceutical;
  bool get isTobaccoMode => industryMode == IndustryMode.tobacco;

  SystemSettings copyWith({
    IndustryMode? industryMode,
    String? systemName,
    String? systemVersion,
    String? defaultTimezone,
    String? dateFormat,
    String? dateTimeFormat,
  }) {
    return SystemSettings(
      industryMode: industryMode ?? this.industryMode,
      systemName: systemName ?? this.systemName,
      systemVersion: systemVersion ?? this.systemVersion,
      defaultTimezone: defaultTimezone ?? this.defaultTimezone,
      dateFormat: dateFormat ?? this.dateFormat,
      dateTimeFormat: dateTimeFormat ?? this.dateTimeFormat,
    );
  }
}

/// Statistics about data that would be cleared when switching modes.
class DataClearStatistics {
  final int gtinCount;
  final int sgtinCount;
  final int glnCount;
  final int eventCount;
  final int tobaccoExtensionCount;
  final int pharmaceuticalExtensionCount;
  final int taxStampCount;
  final int manufacturingBatchCount;

  const DataClearStatistics({
    this.gtinCount = 0,
    this.sgtinCount = 0,
    this.glnCount = 0,
    this.eventCount = 0,
    this.tobaccoExtensionCount = 0,
    this.pharmaceuticalExtensionCount = 0,
    this.taxStampCount = 0,
    this.manufacturingBatchCount = 0,
  });

  factory DataClearStatistics.fromJson(Map<String, dynamic> json) {
    return DataClearStatistics(
      gtinCount: json['gtinCount'] ?? 0,
      sgtinCount: json['sgtinCount'] ?? 0,
      glnCount: json['glnCount'] ?? 0,
      eventCount: json['eventCount'] ?? 0,
      tobaccoExtensionCount: json['tobaccoExtensionCount'] ?? 0,
      pharmaceuticalExtensionCount: json['pharmaceuticalExtensionCount'] ?? 0,
      taxStampCount: json['taxStampCount'] ?? 0,
      manufacturingBatchCount: json['manufacturingBatchCount'] ?? 0,
    );
  }

  /// Total number of records that would be cleared.
  int get totalRecords =>
      gtinCount +
      sgtinCount +
      glnCount +
      eventCount +
      tobaccoExtensionCount +
      pharmaceuticalExtensionCount +
      taxStampCount +
      manufacturingBatchCount;

  /// Check if there's any data to clear.
  bool get hasData => totalRecords > 0;
}
