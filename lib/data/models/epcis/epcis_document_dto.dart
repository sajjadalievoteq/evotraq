import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';

/// Data Transfer Object for EPCIS document that can contain multiple events.
/// This follows the structure of EPCIS 2.0 but maintains compatibility with 1.3.
class EPCISDocumentDTO {
  /// EPCIS standard version
  final String epcisVersion;
  
  /// Unique document identifier
  final String documentId;
  
  /// Document creation date
  final DateTime creationDate;
  
  /// Schema version
  final String schemaVersion;
  
  /// Context information (namespaces and definitions)
  final Map<String, String> context;
  
  /// List of EPCIS events in the document
  final List<EPCISEvent> events;
  
  /// Master data related to the events
  final Map<String, dynamic> masterData;

  /// Constructor
  EPCISDocumentDTO({
    required this.epcisVersion,
    required this.documentId,
    required this.creationDate,
    required this.schemaVersion,
    required this.context,
    required this.events,
    required this.masterData,
  });
  /// Create from JSON
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
  /// Convert to JSON
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

  /// Helper method to format dates with timezone information.
  /// Always converts to UTC so the ISO string carries the 'Z' suffix
  /// and the backend deserializer never has to guess the timezone.
  String _formatDateWithTimezone(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
