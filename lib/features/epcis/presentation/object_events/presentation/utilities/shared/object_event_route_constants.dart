import 'package:traqtrace_app/core/consts/app_consts.dart';

/// Route paths and helpers for object event navigation.
abstract final class ObjectEventRouteConstants {
  static const String queryEventId = 'eventId';

  /// Detail screen path — event ID is passed as a query param so NI URIs
  /// (`ni:///sha-256;…`) work on mobile and web without breaking go_router.
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
