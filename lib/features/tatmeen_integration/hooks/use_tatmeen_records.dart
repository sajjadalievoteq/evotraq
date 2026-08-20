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

  Future<TatmeenRetryOutcome> retryRecord(String operationId) async {
    if (_inFlightIds.contains(operationId)) {
      return TatmeenRetryOutcome.failure('Already retrying this record.');
    }
    _inFlightIds.add(operationId);
    notifyListeners();
    try {
      final outcome = await _service.retrySyncRecord(operationId);
      await _fetch(silent: true);
      return outcome;
    } on ApiException catch (e) {
      return TatmeenRetryOutcome.failure(_friendlyApiError(e));
    } catch (_) {
      return TatmeenRetryOutcome.failure(
        'An unexpected error occurred. Please try again.',
      );
    } finally {
      _inFlightIds.remove(operationId);
      notifyListeners();
    }
  }

  static String _friendlyApiError(ApiException e) {
    return switch (e.statusCode) {
      null => 'Network error. Check your internet connection and try again.',
      401 => 'Your session has expired. Please log in again.',
      403 => 'You don\'t have permission to retry this record.',
      404 =>
        'This record was not found — it may have already been processed or removed.',
      500 => 'Server error. Please try again in a moment.',
      _ => e.getUserFriendlyMessage(),
    };
  }

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
