part of 'aggregation_event_form_screen.dart';

extension AggregationEventFormFields on _AggregationEventFormScreenState {
  void _addChildEpc([String value = '']) {
    setState(
      () => _childEpcControllers.add(TextEditingController(text: value)),
    );
  }

  void _removeChildEpc(int index) {
    setState(() {
      _childEpcControllers.removeAt(index).dispose();
    });
  }

  Future<void> _scanAndAddChildEpc() async {
    final value = await Gs1FieldBarcodeScan.scan(
      context,
      Gs1FieldScanKind.sgtin,
    );
    if (value != null && value.isNotEmpty && mounted) {
      _addChildEpc(value);
    }
  }

  void _addQuantityRow() {
    setState(
      () => _quantityRows.add(AggregationEventFormQuantityRowControllers()),
    );
  }

  void _removeQuantityRow(
    int index,
    AggregationEventFormQuantityRowControllers row,
  ) {
    setState(() {
      row.dispose();
      _quantityRows.removeAt(index);
    });
  }

  void _addBizDataField() {
    setState(() {
      _bizDataControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeBizDataField(int index) {
    setState(() {
      final entry = _bizDataControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void _addSourceEntry() {
    setState(() {
      _sourceListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeSourceEntry(int index) {
    setState(() {
      final entry = _sourceListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void _addDestinationEntry() {
    setState(() {
      _destinationListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeDestinationEntry(int index) {
    setState(() {
      final entry = _destinationListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  List<Map<String, dynamic>> _getSourceList() {
    final sourceList = <Map<String, dynamic>>[];
    for (final entry in _sourceListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        sourceList.add({'type': type, 'source': value});
      }
    }
    return sourceList;
  }

  List<Map<String, dynamic>> _getDestinationList() {
    final destinationList = <Map<String, dynamic>>[];
    for (final entry in _destinationListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        destinationList.add({'type': type, 'destination': value});
      }
    }
    return destinationList;
  }

  Future<void> _selectEventTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && mounted) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventTime),
      );

      if (timePicked != null) {
        setState(() {
          _isManualTime = true;
          _timer?.cancel();
          _eventTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }
}
