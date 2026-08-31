import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_hover_action.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_visual.dart';

/// Application-wide full-content error state.
///
/// Pass the original [error] whenever it is available. Network failures are
/// then detected consistently and use the dedicated offline presentation.
/// For non-network failures, [iconAsset] should match the current screen.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.error,
    this.message,
    this.iconAsset,
    this.title,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.footer,
    this.density = EmptyStateDensity.auto,
  });

  final Object? error;
  final String? message;
  final String? iconAsset;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Widget? footer;
  final EmptyStateDensity density;

  @override
  Widget build(BuildContext context) {
    final networkError = AppErrorClassifier.isNetworkError(
      error,
      message: message,
    );
    final effectiveTitle =
        title ??
        (networkError ? 'No Internet Connection' : 'Something Went Wrong');
    final effectiveMessage = networkError
        ? 'Check your internet connection and try again.'
        : AppErrorClassifier.displayMessage(error, fallback: message);

    return EmptyStateVisualScaffold(
      iconAsset: networkError
          ? AppAssets.iconWifiOff
          : (iconAsset ?? AppAssets.iconAlert),
      title: effectiveTitle,
      subtitle: effectiveMessage,
      actions: onRetry == null
          ? const []
          : [
              EmptyStateHoverAction(
                child: CustomButtonWidget(
                  title: retryLabel,
                  iconAsset: AppAssets.iconRefresh,
                  onTap: onRetry,
                ),
              ),
            ],
      footer: footer,
      density: density,
      semanticsLabel: '$effectiveTitle. $effectiveMessage',
    );
  }
}

abstract final class AppErrorClassifier {
  static bool isNetworkError(Object? error, {String? message}) {
    if (error is ApiException) {
      if (error.statusCode == null) return true;
      return isNetworkError(error.originalException, message: error.message);
    }

    if (error is DioException) {
      return ApiExceptionMapper.isNetworkFailure(error);
    }

    final value = '${message ?? ''} ${error ?? ''}'.toLowerCase();
    return _networkMarkers.any(value.contains);
  }

  static String displayMessage(Object? error, {String? fallback}) {
    final supplied = fallback?.trim();
    if (supplied != null && supplied.isNotEmpty) return supplied;
    if (error is ApiException) return error.getUserFriendlyMessage();
    final raw = error?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      return raw
          .replaceFirst(RegExp(r'^(Exception|ApiException):\s*'), '')
          .trim();
    }
    return 'The requested information could not be loaded. Please try again.';
  }

  static const _networkMarkers = <String>[
    'network error',
    'no internet',
    'internet connection',
    'connection failed',
    'connection refused',
    'connection timed out',
    'connection timeout',
    'receive timeout',
    'send timeout',
    'socketexception',
    'failed host lookup',
    'network is unreachable',
    'connection reset',
    'dns',
  ];
}
