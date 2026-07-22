import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/config/app_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/main.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

void main() {
  testWidgets('TraqTrace app smoke test', (WidgetTester tester) async {
    
    
    await getIt.reset();
    final appConfig = AppConfig(
      apiBaseUrl: 'http://localhost:8080/api',
      appName: 'TraqTrace Test',
      appVersion: '0.0.0-test',
    );
    await initDependencies(appConfig);
    getIt.registerSingleton<AppRouter>(
      AppRouter(authCubit: getIt<AuthCubit>()),
    );

    
    getIt<WebSocketService>().initialize(getIt<AppConfig>().apiBaseUrl, '');

    
    
    await tester.pumpWidget(const TraqTraceApp());

    
    expect(find.byType(MaterialApp), findsOneWidget);

    
    await tester.pumpAndSettle();
    await getIt.reset();
  });
}
