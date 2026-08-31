import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

abstract final class SsccCommissionHelper {
  static Future<CommissioningResponse> commissionAllocatedSscc({
    required String ssccCode,
    required String commissioningLocationGln,
    String? readPointGln,
    String? batchLotNumber,
    DateTime? expiryDate,
    DateTime? productionDate,
    String? commissioningReference,
  }) async {
    final epc = Gs1Converter.ssccToEpc(ssccCode);
    if (epc == null || epc.isEmpty) {
      throw StateError('Could not resolve EPC for SSCC $ssccCode');
    }

    final eventFields = OperationEventTimeCodec.fieldsForRequest(null);
    final request = SsccCommissioningRequest(
      epcUris: [epc],
      commissioningLocationGLN: commissioningLocationGln,
      readPointGLN: readPointGln,
      manufacturingOrigin: '',
      batchLotNumber: batchLotNumber,
      expiryDate: expiryDate,
      productionDate: productionDate,
      commissioningReference: commissioningReference,
      eventTime: eventFields['eventTime'],
      eventTimeZoneOffset: eventFields['eventTimeZoneOffset'],
    );

    return getIt<CommissioningOperationService>()
        .createSsccCommissioningOperation(request);
  }
}
