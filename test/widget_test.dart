import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/main.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

void main() {
  testWidgets('TraqTrace app smoke test', (WidgetTester tester) async {
    // Initialize dependencies for the test environment
    // We reset GetIt to ensure a clean state
    await getIt.reset();
    final appConfig = AppConfig(
      apiBaseUrl: 'http://localhost:8080/api',
      appName: 'TraqTrace Test',
      appVersion: '0.0.0-test',
    );
    await initDependencies(appConfig);

    // Initialize services that require manual setup as done in main.dart
    getIt<WebSocketService>().initialize(getIt<AppConfig>().apiBaseUrl, '');

    // Build our app and trigger a frame.
    // TraqTraceApp no longer takes appConfig in its constructor
    await tester.pumpWidget(const TraqTraceApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
