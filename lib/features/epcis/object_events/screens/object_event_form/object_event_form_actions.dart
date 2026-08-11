part of 'object_event_form_screen.dart';

extension ObjectEventFormActions on _ObjectEventFormScreenState {
  String? _getFieldError(String fieldName) {
    return context.read<ValidationCubit>().getFieldError(fieldName);
  }

  bool _hasFieldBeenValidated(String fieldName) {
    return context.read<ValidationCubit>().hasBeenValidated(fieldName);
  }

  void _setFieldError(String fieldName, String? error) {
    context.read<ValidationCubit>().setFieldError(fieldName, error);
  }

  void _markFieldAsValid(String fieldName) {
    context.read<ValidationCubit>().markFieldAsValid(fieldName);
  }

  void _validateField(
    String fieldName,
    String value,
    String? Function(String) validator,
  ) {
    context.read<ValidationCubit>().validateField(fieldName, value, validator);
  }

  bool _isMandatory(String fieldName) =>
      ObjectEventFormMandatoryFields.isFieldMandatory(
        fieldName: fieldName,
        action: _action,
        businessStep: _businessStep,
        epcListEmpty: _epcList.isEmpty,
        quantityListEmpty: _quantityList.isEmpty,
        epcList: _epcList,
      );

  String? get _effectiveItemDisposition =>
      widget.currentItemDisposition ?? _queryItemDisposition;

  List<String> _allowedActionsForItemState() {
    final d = _effectiveItemDisposition;
    if (d == null) return objectEventActions;

    if (d.endsWith('inactive') ||
        d.endsWith('destroyed') ||
        d.endsWith('decommissioned')) {
      return [];
    }

    if (d.endsWith('active') ||
        d.endsWith('sellable_accessible') ||
        d.endsWith('sellable_not_accessible') ||
        d.endsWith('in_transit') ||
        d.endsWith('in_progress') ||
        d.endsWith('dispensed') ||
        d.endsWith('retail_sold') ||
        d.endsWith('returned')) {
      return ['OBSERVE', 'DELETE'];
    }

    if (d.endsWith('encoded')) {
      return ['ADD'];
    }

    return objectEventActions;
  }

  void _applyDispositionContextActions() {
    final allowed = _allowedActionsForItemState();
    if (_effectiveItemDisposition == null || allowed.isEmpty) return;
    if (allowed.length == 1 || !allowed.contains(_action)) {
      setState(() => _action = allowed.first);
    }
  }

  bool _shouldShowIlmdSection() {
    if (_action != 'ADD') return false;
    if (!CbvVocabularyFormatter.isBizStepCommissioning(_businessStep)) {
      return false;
    }
    return _epcList.any(Gs1CanonicalIdentifier.isSgtin);
  }

  void _syncIlmdState() {
    if (!_shouldShowIlmdSection()) {
      _ilmd.clear();
    }
  }

  void _formatCbvFieldsForVersion(EPCISVersion version) {
    final versionString = version == EPCISVersion.v2_0 ? '2.0' : '1.3';
    if (_businessStep != null) {
      _businessStep = CbvVocabularyFormatter.formatBizStep(
        versionString,
        _businessStep!,
      );
    }
    if (_disposition != null) {
      _disposition = CbvVocabularyFormatter.formatDisposition(
        versionString,
        _disposition!,
      );
    }
  }

  void _onActionChanged(String? newAction) {
    setState(() {
      _action = newAction;
      _syncIlmdState();
    });
  }

  void _onBusinessStepChanged(String? value) {
    setState(() {
      _businessStep = value;
      _syncIlmdState();
    });
  }

  Future<void> _selectEventTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _eventTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationErrors = [];
    });

    final result = await ObjectEventFormSaveHandler.save(
      context: context,
      formKey: _formKey,
      data: ObjectEventFormSaveData(
        eventTime: _eventTime,
        eventTimeZone: _eventTimeZone,
        action: _action,
        businessStep: _businessStep,
        disposition: _disposition,
        readPointGLN: _readPoint?.glnCode,
        businessLocationGLN: _businessLocation?.glnCode,
        epcList: _epcList,
        epcClassList: _epcClassList,
        quantityList: _quantityList,
        bizData: _bizData,
        sourceList: _sourceList,
        destinationList: _destinationList,
        persistentDisposition: _persistentDisposition,
        sensorElementList: _sensorElementList,
        certificationInfoList: _certificationInfoList,
        epcisVersion: _epcisVersion,
        ilmd: Map<String, Object>.from(_ilmd),
      ),
      existingEvent: widget.event,
      embedded: widget.embedded,
      onEmbeddedActionSuccess: widget.onEmbeddedActionSuccess,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = result.errorMessage;
      _validationErrors = result.validationErrors;
    });
  }
}
