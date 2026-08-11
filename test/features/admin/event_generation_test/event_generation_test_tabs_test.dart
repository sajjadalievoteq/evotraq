import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_data_management_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_generator_tab.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_simulation_tab.dart';

void main() {
  testWidgets('event generation tabs render their default states', (
    tester,
  ) async {
    final tabs = <Widget>[
      EventGeneratorTab(
        selectedEventType: 'OBJECT',
        isBulkGeneration: false,
        bulkCount: 100,
        isLoading: false,
        lastBulkResult: null,
        onEventTypeChanged: (_) {},
        onBulkGenerationChanged: (_) {},
        onBulkCountChanged: (_) {},
        onGenerate: () {},
      ),
      EventSimulationTab(
        activeSimulation: null,
        simulationStatus: null,
        simulationParams: const {
          'duration': 300,
          'eventInterval': 1000,
          'includeAnomalies': false,
          'anomalyRate': 0.05,
        },
        isLoading: false,
        statusColor: Colors.blue,
        statusText: 'Ready',
        onDurationChanged: (_) {},
        onEventIntervalChanged: (_) {},
        onIncludeAnomaliesChanged: (_) {},
        onAnomalyRateChanged: (_) {},
        onStart: () {},
        onStop: () {},
        onRefresh: () {},
        onClear: () {},
      ),
      EventDataManagementTab(
        statistics: null,
        activeEnvironment: null,
        isLoading: false,
        onRefresh: () {},
        onCleanTestData: () {},
        onCleanObjectEvents: () {},
        onCleanGlnData: () {},
        onCleanGtinData: () {},
        onCleanSgtinData: () {},
        onCleanSsccTestData: () {},
        onCleanAllSsccData: () {},
        onCleanAggregationEvents: () {},
        onCleanTransactionEvents: () {},
        onCleanTransformationEvents: () {},
      ),
    ];

    for (final tab in tabs) {
      await tester.pumpWidget(
        MaterialApp(
          theme: TraqTheme.light(),
          home: Scaffold(body: tab),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
