import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/app_network_exception.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

void main() {
  test('classifies transport failures as network errors', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/gtins'),
      type: DioExceptionType.connectionError,
    );
    expect(AppErrorClassifier.isNetworkError(error), isTrue);
    expect(ApiExceptionMapper.isNetworkFailure(error), isTrue);
    final normalized = AppNetworkException.from(error);
    expect(normalized, isA<DioException>());
    expect(normalized.toString(), ApiExceptionMapper.networkErrorMessage);
    expect(
      ApiExceptionMapper.fromDio(
        error,
        fallbackMessage: 'Failed to load SSCCs.',
      ).getUserFriendlyMessage(),
      ApiExceptionMapper.networkErrorMessage,
    );
    expect(
      AppErrorClassifier.isNetworkError(null, message: 'Failed host lookup'),
      isTrue,
    );
    expect(
      AppErrorClassifier.isNetworkError(null, message: 'Invalid GTIN'),
      isFalse,
    );
  });

  testWidgets('shows network copy instead of the screen error icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            message: 'Network error. Please check your connection.',
            iconAsset: AppAssets.iconGtin,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a screen-specific error and its message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            title: 'Unable to load GTINs',
            message: 'The GTIN service rejected the request.',
            iconAsset: AppAssets.iconGtin,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Unable to load GTINs'), findsOneWidget);
    expect(find.text('The GTIN service rejected the request.'), findsOneWidget);
  });
}
