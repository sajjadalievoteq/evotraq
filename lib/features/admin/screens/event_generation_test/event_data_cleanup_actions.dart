import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_actions.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/event_generation_test_screen.dart';

extension EventDataCleanupActions on EventGenerationTestScreenState {
  Future<void> cleanTestData() async {
    if (testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cleanup'),
        content: const Text('This will delete all test data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.cleanTestData({});

      context.showSuccess(
        'Cleaned ${result.deletedEvents} events, '
        '${result.deletedGLNs} GLNs, ${result.deletedGTINs} GTINs',
      );

      await loadDataManagementData();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to clean test data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> cleanTransformationEvents() async {
    if (testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transformation Events Cleanup'),
        content: const Text(
          'This will delete all transformation event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.cleanTransformationEvents();

      context.showSuccess(
        'Cleaned ${result['deletedTransformationEvents']} transformation events',
      );

      await loadDataManagementData();
    } catch (e) {
      setState(() {
        errorMessage =
            'Failed to clean transformation events: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> cleanTransactionEvents() async {
    if (testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transaction Events Cleanup'),
        content: const Text(
          'This will delete all transaction event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.cleanTransactionEvents();

      context.showSuccess(
        'Cleaned ${result['deletedTransactionEvents']} transaction events',
      );

      await loadDataManagementData();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to clean transaction events: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> cleanAggregationEvents() async {
    if (testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Aggregation Events Cleanup'),
        content: const Text(
          'This will delete all aggregation event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.cleanAggregationEvents();

      context.showSuccess(
        'Cleaned ${result['deletedAggregationEvents']} aggregation events',
      );

      await loadDataManagementData();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to clean aggregation events: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> cleanObjectEvents() async {
    if (testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Object Events Cleanup'),
        content: const Text(
          'This will delete all object event test data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await testService!.cleanObjectEvents();

      context.showSuccess(
        'Cleaned ${result['deletedObjectEvents']} object events',
      );

      await loadDataManagementData();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to clean object events: ${e.toString()}';
        isLoading = false;
      });
    }
  }
}
