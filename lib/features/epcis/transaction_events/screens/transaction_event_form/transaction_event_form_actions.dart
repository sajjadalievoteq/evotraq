import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/cubit/transaction_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/transaction_events/screens/transaction_event_form/transaction_event_form_screen.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

extension TransactionEventFormActions on TransactionEventFormScreenState {
  Future<void> loadTransactionEvent() async {
    if (widget.transactionEventId == null) return;

    final event = await context
        .read<TransactionEventsCubit>()
        .getTransactionEventById(widget.transactionEventId!);

    if (event != null) {
      setState(() {
        selectedAction = event.action;
        eventTime = event.eventTime;

        if (event.bizTransactionList.isNotEmpty) {
          final entry = event.bizTransactionList.entries.first;
          bizTransactionTypeController.text = entry.key;
          bizTransactionIdController.text = entry.value;
          if (standardBizTransactionTypes.contains(entry.key)) {
            bizTransactionType = entry.key;
          }
        }

        epcsController.text = event.epcList?.join(', ') ?? '';

        locationGLNController.text = event.businessLocation?.glnCode ?? '';

        businessStep = event.businessStep;

        disposition = event.disposition;

        bizDataControllers.clear();
        if (event.bizData != null && event.bizData!.isNotEmpty) {
          event.bizData!.forEach((key, value) {
            final keyController = TextEditingController(text: key);
            final valueController = TextEditingController(text: value);
            bizDataControllers.add(MapEntry(keyController, valueController));
          });
        } else {
          addBizDataField();
        }
      });
    }
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

  Future<void> saveTransactionEvent() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<TransactionEventsCubit>();

    final resolvedBizTransactionType =
        bizTransactionType ?? bizTransactionTypeController.text.trim();
    final bizTransactionId = bizTransactionIdController.text.trim();
    final epcs = epcsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
        .toList();
    final locationGLN = locationGLNController.text.trim();
    final resolvedBusinessStep = businessStep ?? '';
    final resolvedDisposition = disposition ?? '';

    final bizData = <String, String>{};
    for (var entry in bizDataControllers) {
      final key = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        bizData[key] = value;
      }
    }

    try {
      if (isEdit) {
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        final event = TransactionEvent(
          id: widget.transactionEventId,
          eventId: widget.transactionEventId ?? '',
          eventTime: eventTime,
          recordTime: DateTime.now(),
          eventTimeZoneOffset: eventTimeZoneOffset,
          epcisVersion: EPCISVersion.v2_0,
          action: selectedAction,
          disposition: resolvedDisposition.isEmpty ? null : resolvedDisposition,
          bizStep: resolvedBusinessStep.isEmpty ? null : resolvedBusinessStep,
          readPoint: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizLocation: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizData: bizData.isEmpty ? null : bizData,
          epcList: epcs.isEmpty ? null : epcs,
          bizTransactionList:
              resolvedBizTransactionType.isEmpty || bizTransactionId.isEmpty
              ? {}
              : {resolvedBizTransactionType: bizTransactionId},
        );

        await cubit.updateTransactionEvent(event);
      } else {
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        if (selectedAction == 'ADD') {
          await cubit.createAddTransactionEvent(
            bizTransactionType: resolvedBizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: resolvedBusinessStep,
            disposition: resolvedDisposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (selectedAction == 'DELETE') {
          await cubit.createDeleteTransactionEvent(
            bizTransactionType: resolvedBizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: resolvedBusinessStep,
            disposition: resolvedDisposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (selectedAction == 'OBSERVE') {
          await cubit.createObserveTransactionEvent(
            bizTransactionType: resolvedBizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: resolvedBusinessStep,
            disposition: resolvedDisposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        }
      }

      if (!mounted) return;

      context.showSuccess(
        isEdit ? 'Transaction event updated' : 'Transaction event created',
      );
      Navigator.pop(context, true);
    } catch (e) {
      context.showError(e.toString());
    }
  }

  void showHelpScreen(BuildContext context) {
    context.push('/epcis/transaction-events/help');
  }
}
