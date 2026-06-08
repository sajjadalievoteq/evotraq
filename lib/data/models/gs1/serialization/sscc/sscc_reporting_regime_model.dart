class SsccReportingRegime {
  const SsccReportingRegime({
    this.id,
    required this.ssccId,
    this.ssccCode,
    required this.regimeCode,
  });

  final int? id;
  final int ssccId;
  final String? ssccCode;
  final String regimeCode;

  factory SsccReportingRegime.fromJson(Map<String, dynamic> json) {
    return SsccReportingRegime(
      id: json['id'] as int?,
      ssccId: json['ssccId'] as int,
      ssccCode: json['ssccCode'] as String?,
      regimeCode: json['regimeCode'] as String? ?? '',
    );
  }
}
