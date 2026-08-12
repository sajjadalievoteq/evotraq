/// Hand-authored sample payloads showing third-party developers exactly what
/// TraqTrace sends for an API/webhook notification, so they can build their
/// receiving endpoint against a real, accurate shape rather than guessing.
///
/// These mirror the actual serialization paths used at delivery time:
///  - JSON: [WebhookServiceImpl.buildWebhookPayload] (backend), which wraps a
///    plain Jackson-serialized `List<EPCISEventDTO>` (default bean naming,
///    ObjectEvent fields included) under `timestamp`/`eventCount`/`source`/`events`.
///  - XML: [EPCISXmlSerializer.serializeEvents] (backend), the raw EPCIS 1.3
///    XML document shape (element order: eventTime, recordTime,
///    eventTimeZoneOffset, eventID, then type-specific fields, then the common
///    business fields, then bizTransactionList/sourceList/destinationList/ilmd).
///
/// If either backend serializer's output shape changes, update these samples
/// to match so they stay trustworthy references.
class SubscriptionSamplePayloads {
  SubscriptionSamplePayloads._();

  static const String jsonMimeType = 'application/json';
  static const String xmlMimeType = 'application/xml';

  static const String jsonFilename = 'traqtrace-notification-sample.json';
  static const String xmlFilename = 'traqtrace-notification-sample.xml';

  static const String jsonSample = '''
{
  "timestamp": "2026-08-12T09:15:00Z",
  "eventCount": 1,
  "source": "TraqTrace",
  "events": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "eventId": "ni:///sha-256;3f4b8a...?ver=CBV2.0",
      "eventType": "ObjectEvent",
      "eventTime": "2026-08-12T09:14:32.451Z",
      "recordTime": "2026-08-12T09:14:33.102Z",
      "eventTimeZoneOffset": "+00:00",
      "epcisVersion": "2.0",
      "businessStep": "urn:epcglobal:cbv:bizstep:shipping",
      "disposition": "urn:epcglobal:cbv:disp:in_transit",
      "readPoint": "urn:epc:id:sgln:0614141.00001.0",
      "businessLocation": "urn:epc:id:sgln:0614141.00002.0",
      "bizData": {
        "operation_reference_number": "0614141000005-SHP-20260812-000001"
      },
      "eventHash": "sha256:9f1c2a...",
      "createdAt": "2026-08-12T09:14:33.150Z",
      "bizTransactionList": [
        {
          "type": "urn:epcglobal:cbv:btt:po",
          "bizTransaction": "urn:epcglobal:cbv:bt:0614141073467:PO-1000001"
        }
      ],
      "errorDeclaration": null,
      "sensorElementList": null,
      "certificationInfo": null,
      "epcList": [
        "urn:epc:id:sgtin:0614141.107346.2017",
        "urn:epc:id:sgtin:0614141.107346.2018"
      ],
      "action": "OBSERVE",
      "quantityList": null,
      "sourceList": [
        {
          "type": "urn:epcglobal:cbv:sdt:owning_party",
          "source": "urn:epc:id:pgln:0614141.00001"
        }
      ],
      "destinationList": [
        {
          "type": "urn:epcglobal:cbv:sdt:owning_party",
          "destination": "urn:epc:id:pgln:0614141.00002"
        }
      ],
      "ilmd": null,
      "persistentDisposition": null
    }
  ]
}
''';

  static const String xmlSample = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epcis:EPCISDocument xmlns:epcis="urn:epcglobal:epcis:xsd:1" schemaVersion="1.3" creationDate="2026-08-12T09:15:00Z">
  <EPCISHeader/>
  <EPCISBody>
    <EventList>
      <ObjectEvent>
        <eventTime>2026-08-12T09:14:32.451Z</eventTime>
        <recordTime>2026-08-12T09:14:33.102Z</recordTime>
        <eventTimeZoneOffset>+00:00</eventTimeZoneOffset>
        <eventID>ni:///sha-256;3f4b8a...?ver=CBV2.0</eventID>
        <epcList>
          <epc>urn:epc:id:sgtin:0614141.107346.2017</epc>
          <epc>urn:epc:id:sgtin:0614141.107346.2018</epc>
        </epcList>
        <action>OBSERVE</action>
        <bizStep>urn:epcglobal:cbv:bizstep:shipping</bizStep>
        <disposition>urn:epcglobal:cbv:disp:in_transit</disposition>
        <readPoint>
          <id>urn:epc:id:sgln:0614141.00001.0</id>
        </readPoint>
        <bizLocation>
          <id>urn:epc:id:sgln:0614141.00002.0</id>
        </bizLocation>
        <bizTransactionList>
          <bizTransaction type="urn:epcglobal:cbv:btt:po">urn:epcglobal:cbv:bt:0614141073467:PO-1000001</bizTransaction>
        </bizTransactionList>
        <sourceList>
          <source type="urn:epcglobal:cbv:sdt:owning_party">urn:epc:id:pgln:0614141.00001</source>
        </sourceList>
        <destinationList>
          <destination type="urn:epcglobal:cbv:sdt:owning_party">urn:epc:id:pgln:0614141.00002</destination>
        </destinationList>
      </ObjectEvent>
    </EventList>
  </EPCISBody>
</epcis:EPCISDocument>
''';
}
