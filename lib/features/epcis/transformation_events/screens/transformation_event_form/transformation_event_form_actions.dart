part of 'transformation_event_form_screen.dart';

extension TransformationEventFormActions
    on _TransformationEventFormScreenState {
  Future<void> _saveEvent() async {
    setState(() {
      _hasTriedToSubmit = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cubit = context.read<TransformationEventsCubit>();
      final validationCubit = context.read<ValidationCubit>();

      final inputEpcs = _inputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();

      final outputEpcs = _outputEpcsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => EPCFormatter.formatToEPCUri(e) ?? e)
          .toList();

      final Map<String, String> bizData = Map.from(_bizData);

      final String locationGLN = _locationGLNController.text.trim();
      if (locationGLN.isNotEmpty) {
        bizData['locationGLNCode'] = locationGLN;

        bizData['businessLocationGLN'] = locationGLN;
        bizData['bizLocationGLN'] = locationGLN;
      }

      String transformationId = _transformationIdController.text;
      if (!transformationId.startsWith('urn:') &&
          !transformationId.startsWith('http://') &&
          !transformationId.startsWith('https://')) {
        transformationId = 'urn:traqtrace:transformation:$transformationId';
      }

      String? bizStep = _bizStepController.text.isNotEmpty
          ? _bizStepController.text
          : null;
      String? disposition = _dispositionController.text.isNotEmpty
          ? _dispositionController.text
          : null;

      GLN? businessLocationGLN;
      GLN? readPointGLN;
      if (locationGLN.isNotEmpty) {
        businessLocationGLN = GLN.fromCode(locationGLN);
        readPointGLN = GLN.fromCode(locationGLN);
      }

      List<CertificationInfo>? certificationInfo;
      if (_certificateNumberController.text.isNotEmpty ||
          _certificationStandardController.text.isNotEmpty ||
          _certificationAgencyController.text.isNotEmpty ||
          _certificationTypeController.text.isNotEmpty) {
        certificationInfo = [
          CertificationInfo(
            certificateId: _certificateNumberController.text.isNotEmpty
                ? _certificateNumberController.text
                : null,
            certificationStandard:
                _certificationStandardController.text.isNotEmpty
                ? _certificationStandardController.text
                : null,
            certificationAgency: _certificationAgencyController.text.isNotEmpty
                ? _certificationAgencyController.text
                : null,
            certificationType: _certificationTypeController.text.isNotEmpty
                ? _certificationTypeController.text
                : null,
          ),
        ];
      }

      final event = TransformationEvent(
        id: _isEdit ? widget.event?.id : null,
        eventId: _isEdit ? widget.event?.eventId ?? '' : const Uuid().v4(),
        eventTime: _eventTime,
        recordTime: DateTime.now(),
        eventTimeZoneOffset: _eventTimeZoneOffset,
        bizStep: bizStep,
        disposition: disposition,
        readPoint: readPointGLN,
        bizLocation: businessLocationGLN,
        bizData: bizData,
        transformationID: transformationId,
        inputEPCList: inputEpcs,
        outputEPCList: outputEpcs,
        certificationInfo: certificationInfo,
      );

      final isValid = await validationCubit.validateTransformationEvent(event);

      if (!isValid && mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (_isEdit && widget.event != null) {
        await cubit.updateTransformationEvent(event);
      } else {
        await cubit.createTransformationEvent(event);
      }

      if (mounted) {
        context.showSuccess(
          'Transformation event ${_isEdit ? "updated" : "created"} successfully',
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        context.showError('Error: ${error.toString()}');
      }
    }
  }

  void _generateSampleInputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '107346');
    setState(() {
      final existingEpcs = _inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _inputEpcsController.text = sgtin;
      } else {
        _inputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void _generateBatchInputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '107346', 3);
    setState(() {
      final existingEpcs = _inputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _inputEpcsController.text = batch.join(', ');
      } else {
        _inputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }

  void _generateSampleOutputEPC() {
    final sgtin = GS1Generator.generateRandomSGTIN('0614141', '207346');
    setState(() {
      final existingEpcs = _outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _outputEpcsController.text = sgtin;
      } else {
        _outputEpcsController.text = '$existingEpcs, $sgtin';
      }
    });
  }

  void _generateBatchOutputEPCs() {
    final batch = GS1Generator.generateBatchSGTINs('0614141', '207346', 3);
    setState(() {
      final existingEpcs = _outputEpcsController.text.trim();
      if (existingEpcs.isEmpty) {
        _outputEpcsController.text = batch.join(', ');
      } else {
        _outputEpcsController.text = '$existingEpcs, ${batch.join(', ')}';
      }
    });
  }

  List<String> _getValidDispositionsForCurrentBusinessStep() {
    final cbvState = context.read<CbvVocabularyCubit>().state;
    if (cbvState.dispositions.isEmpty) {
      return const [];
    }
    if (_bizStepController.text.isEmpty) {
      return cbvState.dispositions.map((item) => item.code).toList();
    }
    final allowedCodes =
        cbvState.bizStepValidDispositions[_bizStepController.text];
    if (allowedCodes == null || allowedCodes.isEmpty) {
      return cbvState.dispositions.map((item) => item.code).toList();
    }
    final allowedSet = allowedCodes.toSet();
    return cbvState.dispositions
        .where((item) => allowedSet.contains(item.code))
        .map((item) => item.code)
        .toList();
  }

  Future<void> _tryRestoreGLNFromBackend(String eventId) async {
    try {
      print('Trying to restore GLN code for event ID: $eventId');
    } catch (e) {
      print('Failed to restore GLN from backend: ${e.toString()}');
    }
  }
}
