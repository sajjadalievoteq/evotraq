class CbvVocabularyItem {
  final String code;
  final String urn;
  final String label;
  final String? group;
  final bool enabled;
  final bool isCustom;
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? updatedAt;

  bool get isSystem => !isCustom;

  const CbvVocabularyItem({
    required this.code,
    required this.urn,
    required this.label,
    required this.enabled,
    this.group,
    this.isCustom = false,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory CbvVocabularyItem.fromJson(Map<String, dynamic> json) {
    return CbvVocabularyItem(
      code: json['code'] as String,
      urn: json['urn'] as String,
      label: (json['label'] as String?) ?? json['code'] as String,
      group: json['group'] as String?,
      enabled: (json['enabled'] as bool?) ?? true,
      isCustom: (json['isCustom'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'urn': urn,
        'label': label,
        'group': group,
        'enabled': enabled,
        'isCustom': isCustom,
        'createdAt': createdAt?.toIso8601String(),
        'createdBy': createdBy,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  CbvVocabularyItem copyWith({
    String? code,
    String? urn,
    String? label,
    String? group,
    bool? enabled,
    bool? isCustom,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return CbvVocabularyItem(
      code: code ?? this.code,
      urn: urn ?? this.urn,
      label: label ?? this.label,
      group: group ?? this.group,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
