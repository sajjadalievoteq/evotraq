class CbvVocabularyItem {
  final String code;
  final String urn;
  final String label;

  const CbvVocabularyItem({
    required this.code,
    required this.urn,
    required this.label,
  });

  factory CbvVocabularyItem.fromJson(Map<String, dynamic> json) {
    return CbvVocabularyItem(
      code: json['code'] as String,
      urn: json['urn'] as String,
      label: json['label'] as String,
    );
  }
}
