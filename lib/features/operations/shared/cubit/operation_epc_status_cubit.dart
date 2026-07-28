import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/operations/shared/epc_status_response.dart';
import 'package:traqtrace_app/data/services/operations/shared/operation_epc_status_service.dart';

class OperationEpcStatusState {
  const OperationEpcStatusState();
}

class OperationEpcStatusCubit extends Cubit<OperationEpcStatusState> {
  OperationEpcStatusCubit({required OperationEpcStatusService service})
      : _service = service,
        super(const OperationEpcStatusState());

  final OperationEpcStatusService _service;
  final Map<String, Future<EpcStatusResponse?>> _cache = {};

  Future<EpcStatusResponse?> loadStatus(String epc) {
    final key = epc.trim();
    if (key.isEmpty) return Future.value(null);
    final cached = _cache[key];
    if (cached != null) return cached;
    final future = _service.getEpcStatus(key);
    _cache[key] = future;
    return future;
  }
}
