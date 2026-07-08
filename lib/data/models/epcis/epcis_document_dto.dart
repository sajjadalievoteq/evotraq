import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';

class EPCISDocumentDTO {
  final String epcisVersion;
  
  final String documentId;
  
  final DateTime creationDate;
  
  final String schemaVersion;
  
  final Map<String, String> context;
  
  final List<EPCISEvent> events;
  
  final Map<String, dynamic> masterData;

  EPCISDocumentDTO({
    required this.epcisVersion,
    required this.documentId,
    required this.creationDate,
    required this.schemaVersion,
    required this.context,
    required this.events,
    required this.masterData,
  });
  factory EPCISDocumentDTO.fromJson(Map<String, dynamic> json) {
    return EPCISDocumentDTO(
      epcisVersion: json['epcisVersion'],
      documentId: json['documentId'],
      creationDate: DateTime.parse(json['creationDate']),
      schemaVersion: json['schemaVersion'],
      context: Map<String, String>.from(json['context']),
      events: (json['events'] as List)
          .map((eventJson) => EPCISEvent.fromJson(eventJson))
          .toList(),
      masterData: Map<String, dynamic>.from(json['masterData']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'epcisVersion': epcisVersion,
      'documentId': documentId,
      'creationDate': _formatDateWithTimezone(creationDate),
      'schemaVersion': schemaVersion,
      'context': context,
      'events': events.map((event) => event.toJson()).toList(),
      'masterData': masterData,
    };
  }

  String _formatDateWithTimezone(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
