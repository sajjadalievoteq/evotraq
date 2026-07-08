class ObjectEventApiConstants {
  ObjectEventApiConstants._();

  static const String basePath = '/events/object';

  static const String queryEventId = 'eventId';
  static const String queryPage = 'page';
  static const String querySize = 'size';
  static const String queryDirection = 'direction';
  static const String queryAction = 'action';
  static const String queryBizStep = 'bizStep';
  static const String queryDisposition = 'disposition';
  static const String queryLocationGln = 'locationGLN';
  static const String querySearchText = 'searchText';
  static const String queryStartTime = 'startTime';
  static const String queryEndTime = 'endTime';
  static const String queryEpcs = 'epcs';
  static const String queryProperty = 'property';
  static const String queryValue = 'value';
  static const String queryEpcClass = 'epcClass';
  static const String queryMin = 'min';
  static const String queryMax = 'max';

  static const String segmentEventId = 'event-id';
  static const String segmentValidate = 'validate';
  static const String segmentBatch = 'batch';
  static const String segmentAction = 'action';
  static const String segmentEpc = 'epc';
  static const String segmentEpcs = 'epcs';
  static const String segmentEpcClass = 'epc-class';
  static const String segmentIlmd = 'ilmd';
  static const String segmentQuantity = 'quantity';
  static const String segmentBusinessStep = 'business-step';
  static const String segmentDisposition = 'disposition';
  static const String segmentLocation = 'location';
  static const String segmentTimeRange = 'time-range';
  static const String segmentStatistics = 'statistics';
  static const String segmentAdd = 'add';
  static const String segmentObserve = 'observe';
  static const String segmentDelete = 'delete';
  static const String segmentSearch = 'search';
  static const String segmentHistory = 'history';

  static const String jsonKeyContent = 'content';
  static const String jsonKeyEvents = 'events';
  static const String jsonKeyEventType = 'eventType';
  static const String jsonKeyEventId = 'eventId';
  static const String jsonKeyAction = 'action';
  static const String jsonKeyBusinessStep = 'businessStep';
  static const String jsonKeyDisposition = 'disposition';
  static const String jsonKeyBizData = 'bizData';
  static const String jsonKeyIlmd = 'ilmd';
  static const String jsonKeySourceList = 'sourceList';
  static const String jsonKeyDestinationList = 'destinationList';
  static const String jsonKeyPersistentDisposition = 'persistentDisposition';
  static const String jsonKeySensorElementList = 'sensorElementList';
  static const String jsonKeyCertificationInfo = 'certificationInfo';

  static const String actionAdd = 'ADD';
  static const String actionObserve = 'OBSERVE';
  static const String actionDelete = 'DELETE';
  static const String jsonKeyEventTime = 'eventTime';
  static const String jsonKeyRecordTime = 'recordTime';
  static const String jsonKeyEpcisVersion = 'epcisVersion';
  static const String jsonKeyEventTimeZoneOffset = 'eventTimeZoneOffset';
  static const String jsonKeyReadPoint = 'readPoint';
  static const String jsonKeyBusinessLocation = 'businessLocation';
  static const String jsonKeyEpcList = 'epcList';
  static const String jsonKeyQuantityList = 'quantityList';

  static const String eventTypeObject = 'ObjectEvent';
  static const String epcisVersion20 = '2.0';
  static const String epcisVersion13 = '1.3';
}
