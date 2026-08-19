import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';

class UseTatmeenRecords extends ChangeNotifier {
  UseTatmeenRecords({
    required TatmeenIntegrationService service,
    required RecordsFilter filter,
  }) : _service = service,
       _status = filter.status;

  final TatmeenIntegrationService _service;
  TatmeenRecordsStatusFilter _status;
  DateTime? _fromDate = DateTime.now().toLocal().subtract(
    const Duration(days: 30),
  );
  DateTime? _toDate = DateTime.now().toLocal();
  String _search = '';
  bool _busy = false;
  bool _initialLoaded = false;
  final Set<String> _inFlightIds = {};

  TatmeenSyncRecordsPage? pageData;
  String? error;

  TatmeenRecordsStatusFilter get status => _status;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get search => _search;
  bool get isLoading => !_initialLoaded && _busy;
  bool get isRefreshing => _initialLoaded && _busy;
  bool get isError => error != null && pageData == null;
  List<TatmeenSyncRecord> get records => pageData?.items ?? const [];
  int get total => pageData?.total ?? 0;
  bool isBusy(String id) => _inFlightIds.contains(id);

  Future<void> load() => _fetch();

  Future<void> refetch() => _fetch();

  void setDraft({
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    if (clearFrom) {
      _fromDate = null;
    } else if (fromDate != null) {
      _fromDate = fromDate;
    }
    if (clearTo) {
      _toDate = null;
    } else if (toDate != null) {
      _toDate = toDate;
    }
    if (search != null) _search = search;
    notifyListeners();
  }

  Future<void> apply() => _fetch();

  Future<void> clear() {
    _fromDate = DateTime.now().toLocal().subtract(const Duration(days: 30));
    _toDate = DateTime.now().toLocal();
    _search = '';
    notifyListeners();
    return _fetch();
  }

  Future<void> retryRecord(String id) => _mutate(id, _service.retrySyncRecord);

  Future<void> dismissRecord(String id) =>
      _mutate(id, _service.dismissSyncRecord);

  Future<void> _mutate(
    String id,
    Future<void> Function(String id) action,
  ) async {
    if (_inFlightIds.contains(id)) return;
    _inFlightIds.add(id);
    notifyListeners();
    try {
      await action(id);
      await _fetch(silent: true);
    } finally {
      _inFlightIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> _fetch({bool silent = false}) async {
    if (_busy) return;
    _busy = true;
    if (!silent) notifyListeners();
    try {
      pageData = await _service.getSyncRecords(
        TatmeenRecordsQuery(
          status: _status,
          fromDate: _fromDate,
          toDate: _toDate,
          search: _search,
          page: 1,
          pageSize: 1000,
        ),
      );
      error = null;
      _initialLoaded = true;
    } catch (e) {
      error = e is ApiException ? e.getUserFriendlyMessage() : e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
