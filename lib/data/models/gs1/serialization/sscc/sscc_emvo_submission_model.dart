class SsccEmvoSubmission {
  const SsccEmvoSubmission({
    this.id,
    required this.ssccId,
    this.ssccCode,
    required this.eventId,
    required this.status,
    this.submittedAt,
    this.acknowledgedAt,
  });

  final int? id;
  final int ssccId;
  final String? ssccCode;
  final String eventId;
  final String status;
  final DateTime? submittedAt;
  final DateTime? acknowledgedAt;

  factory SsccEmvoSubmission.fromJson(Map<String, dynamic> json) {
    return SsccEmvoSubmission(
      id: json['id'] as int?,
      ssccId: json['ssccId'] as int,
      ssccCode: json['ssccCode'] as String?,
      eventId: json['eventId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.tryParse(json['acknowledgedAt'] as String)
          : null,
    );
  }
}
