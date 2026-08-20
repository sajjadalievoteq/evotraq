import 'dart:async';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/aggregation_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_quantity_row_controllers.dart';

extension AggregationEventFormFields on AggregationEventFormScreenState {
  void addChildEpc([String value = '']) {
    setState(
      () => childEpcControllers.add(TextEditingController(text: value)),
    );
  }

  void removeChildEpc(int index) {
    setState(() {
      childEpcControllers.removeAt(index).dispose();
    });
  }

  Future<void> scanAndAddChildEpc() async {
    final value = await Gs1FieldBarcodeScan.scan(
      context,
      Gs1FieldScanKind.sgtin,
    );
    if (value != null && value.isNotEmpty && mounted) {
      addChildEpc(value);
    }
  }

  void addQuantityRow() {
    setState(
      () => quantityRows.add(AggregationEventFormQuantityRowControllers()),
    );
  }

  void removeQuantityRow(
    int index,
    AggregationEventFormQuantityRowControllers row,
  ) {
    setState(() {
      row.dispose();
      quantityRows.removeAt(index);
    });
  }

  void addBizDataField() {
    setState(() {
      bizDataControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void removeBizDataField(int index) {
    setState(() {
      final entry = bizDataControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void addSourceEntry() {
    setState(() {
      sourceListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void removeSourceEntry(int index) {
    setState(() {
      final entry = sourceListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  void addDestinationEntry() {
    setState(() {
      destinationListControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void removeDestinationEntry(int index) {
    setState(() {
      final entry = destinationListControllers.removeAt(index);
      entry.key.dispose();
      entry.value.dispose();
    });
  }

  List<Map<String, dynamic>> getSourceList() {
    final sourceList = <Map<String, dynamic>>[];
    for (final entry in sourceListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        sourceList.add({'type': type, 'source': value});
      }
    }
    return sourceList;
  }

  List<Map<String, dynamic>> getDestinationList() {
    final destinationList = <Map<String, dynamic>>[];
    for (final entry in destinationListControllers) {
      final type = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (type.isNotEmpty && value.isNotEmpty) {
        destinationList.add({'type': type, 'destination': value});
      }
    }
    return destinationList;
  }

  Future<void> selectEventTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: eventTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && mounted) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(eventTime),
      );

      if (timePicked != null) {
        setState(() {
          isManualTime = true;
          timer?.cancel();
          eventTime = DateTime(
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
