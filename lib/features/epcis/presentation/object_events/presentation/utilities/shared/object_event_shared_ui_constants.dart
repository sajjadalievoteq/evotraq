class ObjectEventSharedUiConstants {
  ObjectEventSharedUiConstants._();

  static const String appBarManagement = 'Object Events';
  static const String splitCreateHeader = 'New Object Event';
  static const String tooltipClose = 'Close';

  static const String actionAdd = 'ADD';
  static const String actionObserve = 'OBSERVE';
  static const String actionDelete = 'DELETE';

  static const String fabHeroTag = 'object_event_add_fab';
  static const String fabAddTooltip = 'Record Object Event';
  static const String fabCloseTooltip = 'Cancel';

  static const String emDash = '—';

  static const String _cbvHttpsPrefix = 'https://ref.gs1.org/cbv/BizStep-';
  static const String _cbvUrnPrefix = 'urn:epcglobal:cbv:bizstep:';

  static String friendlyBizStep(String? bizStep) {
    if (bizStep == null) return emDash;
    var s = bizStep
        .replaceFirst(_cbvHttpsPrefix, '')
        .replaceFirst(_cbvUrnPrefix, '')
        .replaceAll('_', ' ');
    if (s.isEmpty) return bizStep;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String friendlyDisposition(String? disposition) {
    if (disposition == null) return emDash;
    final s = disposition.split('/').last.split(':').last.replaceAll('_', ' ');
    if (s.isEmpty) return disposition;
    return s[0].toUpperCase() + s.substring(1);
  }
}
