part of 'event_generation_test_screen.dart';

extension EventDataCleanupActions on _EventGenerationTestScreenState {
  Future<void> _cleanTestData() async {
    if (_testService == null) return;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTestData({});

      context.showSuccess(
        'Cleaned ${result.deletedEvents} events, '
        '${result.deletedGLNs} GLNs, ${result.deletedGTINs} GTINs',
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanTransformationEvents() async {
    if (_testService == null) return;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTransformationEvents();

      context.showSuccess(
        'Cleaned ${result['deletedTransformationEvents']} transformation events',
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to clean transformation events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanTransactionEvents() async {
    if (_testService == null) return;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanTransactionEvents();

      context.showSuccess(
        'Cleaned ${result['deletedTransactionEvents']} transaction events',
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean transaction events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanAggregationEvents() async {
    if (_testService == null) return;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanAggregationEvents();

      context.showSuccess(
        'Cleaned ${result['deletedAggregationEvents']} aggregation events',
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean aggregation events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanObjectEvents() async {
    if (_testService == null) return;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanObjectEvents();

      context.showSuccess(
        'Cleaned ${result['deletedObjectEvents']} object events',
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean object events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
