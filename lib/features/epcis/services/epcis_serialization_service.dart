import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';

/// Service interface for EPCIS Serialization and Format Conversion operations
abstract class EPCISSerializationService {
  
  /// Convert EPCIS 1.3 XML to EPCIS 2.0 JSON-LD
  /// 
  /// [xmlContent] is the XML content to convert
  /// Returns JSON-LD representation as Map
  Future<Map<String, dynamic>> convertXmlToJsonLd(String xmlContent);
  
  /// Convert EPCIS 2.0 JSON-LD to EPCIS 1.3 XML
  /// 
  /// [jsonLdContent] is the JSON-LD content to convert
  /// Returns XML representation as String
  Future<String> convertJsonLdToXml(Map<String, dynamic> jsonLdContent);
  
  /// Serialize EPCIS document to XML format (EPCIS 1.3)
  /// 
  /// [document] is the EPCIS document to serialize
  /// Returns XML string representation
  Future<String> serializeToXml(EPCISDocumentDTO document);
  
  /// Serialize EPCIS document to JSON-LD format (EPCIS 2.0)
  /// 
  /// [document] is the EPCIS document to serialize
  /// Returns JSON-LD map representation
  Future<Map<String, dynamic>> serializeToJsonLd(EPCISDocumentDTO document);
  
  /// Deserialize XML content to EPCIS document
  /// 
  /// [xmlContent] is the XML content to deserialize
  /// Returns EPCIS document DTO
  Future<EPCISDocumentDTO> deserializeXml(String xmlContent);
  
  /// Deserialize JSON-LD content to EPCIS document
  /// 
  /// [jsonLdContent] is the JSON-LD content to deserialize
  /// Returns EPCIS document DTO
  Future<EPCISDocumentDTO> deserializeJsonLd(Map<String, dynamic> jsonLdContent);
  
  /// Validate XML content against EPCIS 1.3 schema
  /// 
  /// [xmlContent] is the XML content to validate
  /// Returns validation result with errors if any
  Future<Map<String, dynamic>> validateXmlSchema(String xmlContent);
  
  /// Validate JSON content against EPCIS 2.0 schema
  /// 
  /// [jsonContent] is the JSON content to validate
  /// Returns validation result with errors if any
  Future<Map<String, dynamic>> validateJsonSchema(Map<String, dynamic> jsonContent);
  
  /// Export events to CSV format
  /// 
  /// [queryParams] is the query parameters to select events
  /// [includeHeaders] whether to include CSV headers
  /// Returns CSV content as string
  Future<String> exportToCsv(EPCISQueryParametersDTO queryParams, {bool includeHeaders = true});
  
  /// Export events to PDF format
  /// 
  /// [queryParams] is the query parameters to select events
  /// [templateName] is the PDF template name
  /// Returns PDF content as byte array
  Future<List<int>> exportToPdf(EPCISQueryParametersDTO queryParams, {String templateName = 'default'});
  
  /// Export events to HTML format
  /// 
  /// [queryParams] is the query parameters to select events
  /// Returns HTML content as string
  Future<String> exportToHtml(EPCISQueryParametersDTO queryParams);
  
  /// Export events to Excel format
  /// 
  /// [queryParams] is the query parameters to select events
  /// Returns Excel content as byte array
  Future<List<int>> exportToExcel(EPCISQueryParametersDTO queryParams);
  
  /// Get supported MIME types for all export formats
  /// 
  /// Returns map of format to MIME type
  Future<Map<String, String>> getSupportedFormats();
  
  /// Negotiate the best export format based on preferences
  /// 
  /// [acceptHeader] is the HTTP Accept header or format preferences
  /// [supportedFormats] is the list of supported formats
  /// Returns the negotiated format
  Future<String> negotiateFormat(String acceptHeader, List<String> supportedFormats);
  
  /// Import EPCIS events into the database
  /// 
  /// [epcisDocument] is the EPCIS document containing events to import
  /// Returns import result with statistics
  Future<Map<String, dynamic>> importEvents(EPCISDocumentDTO epcisDocument);
  
  /// Import EPCIS events from XML content
  /// 
  /// [xmlContent] is the XML content containing EPCIS events
  /// Returns import result with statistics
  Future<Map<String, dynamic>> importEventsFromXml(String xmlContent);
  
  /// Import EPCIS events from JSON-LD content
  /// 
  /// [jsonLdContent] is the JSON-LD content containing EPCIS events
  /// Returns import result with statistics
  Future<Map<String, dynamic>> importEventsFromJsonLd(Map<String, dynamic> jsonLdContent);
}
