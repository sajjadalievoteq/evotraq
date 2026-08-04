import 'package:traqtrace_app/core/consts/app_consts.dart';

abstract final class ObjectEventRouteConstants {
  static const String queryEventId = 'eventId';

  static const String detailPath =
      '${Constants.epcisObjectEventsRoute}/detail';

  static String detailLocation(String eventId) =>
      '$detailPath?$queryEventId=${Uri.encodeQueryComponent(eventId)}';

  static String? eventIdFromUri(Uri uri) {
    final fromQuery = uri.queryParameters[queryEventId];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
    return null;
  }
}
