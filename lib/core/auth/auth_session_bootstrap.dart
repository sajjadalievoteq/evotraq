import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/auth/browser_document_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/auth/browser_document_web.dart'
    as html;
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

Future<void> bootstrapAuthSession() async {
  final auth = getIt<AuthCubit>();
  final dio = getIt<DioService>();

  if (auth.state.status != AuthStatus.initial) return;

  await dio.warmAuthTokenFromStorage();

  try {
    await auth.checkAuth(minSplashDelay: _startupSplashDelay());
  } catch (e) {
    debugPrint('Startup checkAuth failed: $e');
  }

  if (kIsWeb) {
    html.document.onVisibilityChange.listen((_) async {
      if (html.document.visibilityState == 'visible' &&
          auth.state.isAuthenticated) {
        final tokenManager = getIt<TokenManager>();
        final token = await tokenManager.getToken();
        if (token != null && tokenManager.isExpired(token)) {
          await auth.sessionExpired();
        }
      }
    });
  }

  final status = auth.state.status;
  if (status == AuthStatus.initial || status == AuthStatus.loading) {
    await auth.sessionExpired();
  }

  if (auth.state.isAuthenticated) {
    dio.markAuthSettled();
  }
}

Duration _startupSplashDelay() {
  if (kIsWeb) {
    var path = Uri.base.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.isEmpty || path == '/' || path == Constants.splashRoute) {
      return const Duration(milliseconds: 2000);
    }
    return Duration.zero;
  }
  return const Duration(milliseconds: 2000);
}
