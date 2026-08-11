part of 'event_generation_test_screen.dart';

extension EventMasterDataCleanupActions on _EventGenerationTestScreenState {
  Future<void> _cleanGLNTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm GLN Test Data Cleanup'),
        content: const Text(
          'This will delete all GLNs where location name starts with "Test Location". Are you sure?',
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
      final result = await _testService!.cleanGLNTestData();

      context.showSuccess('Cleaned ${result['deletedGLNs']} test GLNs');

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean GLN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanGTINTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm GTIN Test Data Cleanup'),
        content: const Text(
          'This will delete all GTINs where product name starts with "Test Product". Are you sure?',
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
      final result = await _testService!.cleanGTINTestData();

      context.showSuccess('Cleaned ${result['deletedGTINs']} test GTINs');

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean GTIN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanSGTINTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SGTIN Test Data Cleanup'),
        content: const Text(
          'This will delete all SGTINs where batch lot number starts with "TEST-BATCH-". Are you sure?',
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
      final result = await _testService!.cleanSGTINTestData();

      context.showSuccess('Cleaned ${result['deletedSGTINs']} test SGTINs');

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean SGTIN test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanSSCCTestData() async {
    if (_testService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SSCC Test Data Cleanup'),
        content: const Text(
          'This will delete all SSCCs where GS1 company prefix matches test pharmaceutical companies. Are you sure?',
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
      final result = await _testService!.cleanSSCCTestData();

      context.showSuccess('Cleaned ${result['deletedSSCCs']} test SSCCs');

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to clean SSCC test data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanAllSSCCData() async {
    if (_testService == null) return;

    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DANGER - Delete ALL SSCCs'),
        content: const Text(
          'WARNING: This will delete ALL SSCCs from the system, not just test data!\n\n'
          'This is intended for debugging only when test SSCCs lack proper company prefix data.\n\n'
          'Are you absolutely sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorMapper.warningColor(context),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Understand - Continue'),
          ),
        ],
      ),
    );

    if (firstConfirmed != true) return;

    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FINAL CONFIRMATION'),
        content: const Text(
          'This action CANNOT be undone!\n\n'
          'You are about to delete ALL SSCCs from the entire system.\n\n'
          'Type "DELETE ALL" to confirm:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorMapper.errorColor(context),
            ),
            onPressed: () async {
              final textController = TextEditingController();
              final textConfirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Type Confirmation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Type "DELETE ALL" exactly:'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'DELETE ALL',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorMapper.errorColor(context),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          textController.text == 'DELETE ALL',
                        );
                      },
                      child: const Text('DELETE ALL SSCCs'),
                    ),
                  ],
                ),
              );
              textController.dispose();
              Navigator.pop(context, textConfirmed == true);
            },
            child: const Text('FINAL CONFIRM'),
          ),
        ],
      ),
    );

    if (secondConfirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _testService!.cleanAllSSCCData();

      context.showError(
        'DANGER: Deleted ${result['deletedSSCCs']} SSCCs from system (ALL SSCCs!)',
        duration: const Duration(seconds: 5),
      );

      await _loadDataManagementData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete all SSCC data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
