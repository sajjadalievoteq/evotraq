import 'package:dio/dio.dart';

/// A short, stable Dio network failure used at the application's HTTP edge.
///
/// It remains a [DioException], so existing service catch blocks continue to
/// work, while legacy `error.toString()` paths retain a recognizable network
/// message instead of platform-specific socket details.
class AppNetworkException extends DioException {
  AppNetworkException.from(DioException source)
    : super(
        requestOptions: source.requestOptions,
        response: source.response,
        type: source.type,
        error: source.error,
        stackTrace: source.stackTrace,
        message: messageText,
      );

  static const messageText =
      'Network error. Please check your connection and try again.';

  @override
  String toString() => messageText;
}
