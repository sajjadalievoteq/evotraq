import 'package:dio/dio.dart';

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