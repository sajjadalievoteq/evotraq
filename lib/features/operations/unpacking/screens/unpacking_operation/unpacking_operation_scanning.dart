part of 'unpacking_operation_screen.dart';

extension UnpackingOperationScanning on _UnpackingOperationScreenState {
  void _onContainerScanResult(ScanResult result) {
    if (!result.isValid) return;

    try {
      final parsed = parseToEPC(result.data);
      if (parsed.type != EPCType.sscc && parsed.type != EPCType.sgtin) {
        context.showError(
          'Parent container must be an SSCC (carton/pallet) or SGTIN (product serial).',
        );
        return;
      }
      _onManualContainerAdded(parsed);
      final label = parsed.type == EPCType.sscc
          ? 'SSCC: ${parsed.sscc ?? parsed.raw}'
          : 'SGTIN: ${parsed.epc}';
      context.showSuccess('Container ready — $label');
    } on EPCParseException catch (e) {
      context.showError(e.message);
    }
  }

  Future<void> _loadContainerContents() async {
    if (_parentContainerId == null || _parentContainerId!.isEmpty) return;

    setState(() {
      _isLoadingContents = true;
      _contentsLoadError = null;
    });

    try {
      final contents =
          await UnpackingContainerContentsLoader.loadDirectChildren(
            getIt<HierarchyService>(),
            _parentContainerId!,
          );
      if (!mounted) return;
      setState(() {
        _containerContents = contents;
        _isLoadingContents = false;
        _applyScopeSelection();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingContents = false;
        _contentsLoadError =
            'Could not load container contents. Check your connection and try again.';
        _containerContents = [];
        _selectedEpcs.clear();
      });
    }
  }

  void _onUnpackingScopeChanged(UnpackingScope scope) {
    setState(() {
      _unpackingScope = scope;
      _applyScopeSelection();
    });
  }

  void _applyScopeSelection() {
    if (_unpackingScope == UnpackingScope.wholeContainer) {
      _selectedEpcs
        ..clear()
        ..addAll(_containerContents.map((node) => node.epc));
    } else {
      _selectedEpcs.removeWhere(
        (epc) => !_containerContents.any((node) => node.epc == epc),
      );
    }
  }

  void _onItemSelectionChanged(String epc, bool selected) {
    setState(() {
      if (_unpackingScope == UnpackingScope.wholeContainer) {
        _unpackingScope = UnpackingScope.partial;
      }
      if (selected) {
        _selectedEpcs.add(epc);
      } else {
        _selectedEpcs.remove(epc);
      }
    });
  }

  String? _resolveContainerMemberEpc(String barcode) {
    final uri = Gs1Converter.barcodeToEpc(barcode) ?? barcode;
    final normalized = normalizeHierarchyEpc(uri);
    for (final node in _containerContents) {
      if (normalizeHierarchyEpc(node.epc) == normalized) {
        return node.epc;
      }
    }
    return null;
  }

  void _onItemAdded(EPCParseResult result) {
    _tryAddItemByBarcode(result.epc);
  }

  void _onManualContainerAdded(EPCParseResult result) {
    final validationError = validateParentContainerEpc(result);
    if (validationError != null) {
      context.showError(validationError);
      return;
    }

    setState(() => _parentContainerId = parentContainerIdFromParsed(result));
    _loadContainerContents();
  }

  void _tryAddItemByBarcode(String barcode) {
    final memberEpc = _resolveContainerMemberEpc(barcode);
    if (memberEpc == null) {
      context.showError(
        'This item is not packed in the selected container. '
        'Choose it from the table above or enter an EPC that belongs to '
        'container $_parentContainerId.',
      );
      return;
    }

    if (_selectedEpcs.contains(memberEpc)) {
      context.showError('This item is already selected for unpacking.');
      return;
    }

    final epcError = AggregationEventFormValidators.validateChildEpcEntry(
      barcode,
    );
    if (epcError != null) {
      context.showError(
        'This barcode is not a valid child EPC. '
        'Scan a product serial (SGTIN), lot-based GTIN, or nested SSCC label.',
      );
      return;
    }

    setState(() {
      if (_unpackingScope == UnpackingScope.wholeContainer) {
        _unpackingScope = UnpackingScope.partial;
      }
      _selectedEpcs.add(memberEpc);
    });
    context.showSuccess('Item added ✓');
  }
}
