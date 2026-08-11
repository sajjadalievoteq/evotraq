part of 'transaction_event_form_screen.dart';

extension TransactionEventFormActions on _TransactionEventFormScreenState {
  Future<void> _loadTransactionEvent() async {
    if (widget.transactionEventId == null) return;

    final event = await context
        .read<TransactionEventsCubit>()
        .getTransactionEventById(widget.transactionEventId!);

    if (event != null) {
      setState(() {
        _selectedAction = event.action;
        _eventTime = event.eventTime;

        if (event.bizTransactionList.isNotEmpty) {
          final entry = event.bizTransactionList.entries.first;
          _bizTransactionTypeController.text = entry.key;
          _bizTransactionIdController.text = entry.value;
          if (_standardBizTransactionTypes.contains(entry.key)) {
            _bizTransactionType = entry.key;
          }
        }

        _epcsController.text = event.epcList?.join(', ') ?? '';

        _locationGLNController.text = event.businessLocation?.glnCode ?? '';

        _businessStep = event.businessStep;

        _disposition = event.disposition;

        _bizDataControllers.clear();
        if (event.bizData != null && event.bizData!.isNotEmpty) {
          event.bizData!.forEach((key, value) {
            final keyController = TextEditingController(text: key);
            final valueController = TextEditingController(text: value);
            _bizDataControllers.add(MapEntry(keyController, valueController));
          });
        } else {
          _addBizDataField();
        }
      });
    }
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

  Future<void> _saveTransactionEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<TransactionEventsCubit>();

    final bizTransactionType =
        _bizTransactionType ?? _bizTransactionTypeController.text.trim();
    final bizTransactionId = _bizTransactionIdController.text.trim();
    final epcs = _epcsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
        .toList();
    final locationGLN = _locationGLNController.text.trim();
    final businessStep = _businessStep ?? '';
    final disposition = _disposition ?? '';

    final bizData = <String, String>{};
    for (var entry in _bizDataControllers) {
      final key = entry.key.text.trim();
      final value = entry.value.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        bizData[key] = value;
      }
    }

    try {
      if (_isEdit) {
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        final event = TransactionEvent(
          id: widget.transactionEventId,
          eventId: widget.transactionEventId ?? '',
          eventTime: eventTime,
          recordTime: DateTime.now(),
          eventTimeZoneOffset: _eventTimeZoneOffset,
          epcisVersion: EPCISVersion.v2_0,
          action: _selectedAction,
          disposition: disposition.isEmpty ? null : disposition,
          bizStep: businessStep.isEmpty ? null : businessStep,
          readPoint: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizLocation: locationGLN.isEmpty ? null : GLN.fromCode(locationGLN),
          bizData: bizData.isEmpty ? null : bizData,
          epcList: epcs.isEmpty ? null : epcs,
          bizTransactionList:
              bizTransactionType.isEmpty || bizTransactionId.isEmpty
              ? {}
              : {bizTransactionType: bizTransactionId},
        );

        await cubit.updateTransactionEvent(event);
      } else {
        final eventTime = DateTime.now().subtract(const Duration(seconds: 60));

        if (_selectedAction == 'ADD') {
          await cubit.createAddTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (_selectedAction == 'DELETE') {
          await cubit.createDeleteTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        } else if (_selectedAction == 'OBSERVE') {
          await cubit.createObserveTransactionEvent(
            bizTransactionType: bizTransactionType,
            bizTransactionId: bizTransactionId,
            epcs: epcs,
            locationGLN: locationGLN,
            businessStep: businessStep,
            disposition: disposition,
            bizData: bizData,
            eventTime: eventTime,
          );
        }
      }

      if (!mounted) return;

      context.showSuccess(
        _isEdit ? 'Transaction event updated' : 'Transaction event created',
      );
      Navigator.pop(context, true);
    } catch (e) {
      context.showError(e.toString());
    }
  }

  void _showHelpScreen(BuildContext context) {
    context.push('/epcis/transaction-events/help');
  }
}
