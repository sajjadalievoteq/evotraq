import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';

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

  /// Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Convert to format that Java's ZonedDateTime can parse
    final String iso8601String = dateTime.toIso8601String();
    
    // Check if the string already has timezone information
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }
    
    // Add UTC timezone marker if missing
    return '${iso8601String}Z';
  }
}
