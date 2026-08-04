/// Canonical EPCIS 2.0 JSON-LD import template (bundled asset).
///
/// Shape matches [EPCISJsonLdSerializer] output: `@context`, `type=EPCISDocument`,
/// `schemaVersion`, `epcisBody.eventList` with compact CBV and Digital Link EPCs.
abstract final class EpcisImportTemplate {
  static const String assetPath = 'assets/gs1/epcis-import-template.jsonld';
  static const String downloadFilename = 'epcis-import-template.jsonld';
  static const String mimeType = 'application/ld+json';

  static const String contextUri =
      'https://ref.gs1.org/standards/epcis/2.0.0/epcis-context.jsonld';

  /// Placeholder markers that must be replaced before import.
  static const Set<String> placeholders = {
    'REPLACE_WITH_ISO_CREATION_DATE',
    'REPLACE_WITH_DOCUMENT_URN_UUID',
    'REPLACE_WITH_ISO_EVENT_TIME',
    'REPLACE_WITH_TZ_OFFSET',
    'REPLACE_WITH_EVENT_URN_UUID',
    'REPLACE_WITH_SGTIN_DIGITAL_LINK',
    'REPLACE_WITH_SSCC_DIGITAL_LINK',
    'REPLACE_WITH_LOT_NUMBER',
    'REPLACE_WITH_ISO_DATE_YYYY_MM_DD',
    'REPLACE_WITH_MANUFACTURER_NAME',
  };

  static const Set<String> documentKeys = {
    '@context',
    'type',
    'schemaVersion',
    'creationDate',
    'id',
    'epcisBody',
  };

  static const Set<String> epcisBodyKeys = {'eventList'};

  static const Set<String> sharedEventKeys = {
    'type',
    'eventTime',
    'eventTimeZoneOffset',
    'eventID',
    'recordTime',
    'bizStep',
    'disposition',
    'readPoint',
    'bizLocation',
    'bizTransactionList',
    'errorDeclaration',
    'sensorElementList',
    'certificationInfo',
    'action',
    'sourceList',
    'destinationList',
    'ilmd',
  };

  static const Set<String> objectEventKeys = {
    ...sharedEventKeys,
    'epcList',
    'quantityList',
    'persistentDisposition',
  };

  static const Set<String> aggregationEventKeys = {
    ...sharedEventKeys,
    'parentID',
    'childEPCs',
    'childQuantityList',
  };

  static const Set<String> allowedEventTypes = {
    'ObjectEvent',
    'AggregationEvent',
  };

}
