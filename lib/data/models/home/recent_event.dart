/// Recent EPCIS-style event row for dashboard lists.
class RecentEvent {
  final String id;
  final String eventType;
  final String action;
  final String? bizStep;
  final DateTime eventTime;
  final List<String> epcList;

  RecentEvent({
    required this.id,
    required this.eventType,
    required this.action,
    this.bizStep,
    required this.eventTime,
    required this.epcList,
  });

  factory RecentEvent.fromJson(Map<String, dynamic> json) {
    return RecentEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'Unknown',
      action: json['action']?.toString() ?? '',
      bizStep: json['bizStep']?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      epcList:
          (json['epcList'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
