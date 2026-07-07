import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/epc_status_response.dart';

class OperationEpcStatusService {
  OperationEpcStatusService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  Future<EpcStatusResponse?> getEpcStatus(String epc) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.get(
      '${_dioService.baseUrl}/operations/epc-status',
      queryParameters: {'epc': epc},
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.json,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return EpcStatusResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }
}
