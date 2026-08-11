part of 'sscc_detail_screen.dart';

extension SSCCDetailActions on _SSCCDetailScreenState {
  void _startInitialLoad() {
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) {
      setState(() => _formFieldsHydrated = true);
      return;
    }
    _reloadFromServer();
  }

  String? get _requestedSsccKey => widget.routeSsccCode;

  bool _matchesRequestedSscc(SSCC sscc) {
    final key = _requestedSsccKey;
    if (key == null || key.isEmpty) return false;
    if (RegExp(r'^\d{18}$').hasMatch(key)) {
      return sscc.ssccCode == key;
    }
    return sscc.id?.toString() == key;
  }

  bool _ssccRecordDiffers(SSCC current, SSCC incoming) {
    return current.status != incoming.status ||
        current.packingDate != incoming.packingDate ||
        current.commissionedAt != incoming.commissionedAt ||
        current.childCount != incoming.childCount ||
        current.updatedAt != incoming.updatedAt;
  }

  SSCC? _ssccFromList(SSCCState state, String code) {
    for (final sscc in state.ssccs) {
      if (sscc.ssccCode == code) return sscc;
    }
    return null;
  }

  void _reloadFromServer() {
    if (_serverRefreshInFlight) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) return;

    _serverRefreshInFlight = true;
    _aggregationLinksRequestedCode = null;
    _aggregationLinksFuture = null;
    setState(() {
      _loadedSsccKey = null;
      _formFieldsHydrated = false;
    });
    if (RegExp(r'^\d{18}$').hasMatch(code)) {
      _cubit.fetchSSCCByCode(code);

      _loadAggregationLinks(code);
    } else {
      _cubit.fetchSSCCById(code);
    }
  }

  void _syncDetailWithListIfStale(SSCCState state) {
    if (widget.isCreating || widget.awaitingListSelection) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty || _sscc == null) return;

    final listItem = _ssccFromList(state, code);
    if (listItem == null || !_ssccRecordDiffers(_sscc!, listItem)) return;

    final syncKey =
        '${listItem.updatedAt.toIso8601String()}:${listItem.status.name}';
    if (syncKey == _lastListSyncKey) return;
    _lastListSyncKey = syncKey;
    _reloadFromServer();
  }

  bool _shouldIgnoreCubitError(SSCCState state) {
    if (state.isListLoading) return true;
    return false;
  }

  Future<void> _ensureGlnPickerCatalog() async {
    if (_glnCatalogLoadStarted) return;
    _glnCatalogLoadStarted = true;
    try {
      final catalog = await getIt<GlnPickerCatalog>().ensureLoaded();
      if (!mounted) return;
      setState(() => _glnPickerCatalog = catalog);
      _applyGlnCatalogToFields();
    } catch (_) {}
  }

  Future<void> _refresh() async {
    if (widget.isCreating || widget.awaitingListSelection) return;
    _startInitialLoad();
  }
}
