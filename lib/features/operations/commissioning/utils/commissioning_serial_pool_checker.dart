import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as sgtin_rules;
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';

class CommissioningPoolCheckResult {
  const CommissioningPoolCheckResult({
    required this.status,
    this.sourceStatus,
    this.targetStatus = 'COMMISSIONED',
    this.blockReason,
  });

  final CommissioningSerialPoolStatus status;
  final String? sourceStatus;
  final String? targetStatus;
  final String? blockReason;
}

/// Validates that a parsed EPC exists in the serial pool and can be commissioned.
class CommissioningSerialPoolChecker {
  const CommissioningSerialPoolChecker({
    required SGTINService sgtinService,
    required SSCCService ssccService,
  })  : _sgtinService = sgtinService,
        _ssccService = ssccService;

  final SGTINService _sgtinService;
  final SSCCService _ssccService;

  Future<CommissioningPoolCheckResult> check(EPCParseResult parsed) async {
    try {
      return switch (parsed.type) {
        EPCType.sgtin => await _checkSgtin(parsed),
        EPCType.sscc => await _checkSscc(parsed),
        _ => const CommissioningPoolCheckResult(
            status: CommissioningSerialPoolStatus.notTransitionable,
            blockReason: 'Only SGTIN and SSCC identifiers can be commissioned',
          ),
      };
    } catch (_) {
      return const CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.unknown,
        blockReason: 'Pool lookup failed — try again',
      );
    }
  }

  Future<CommissioningPoolCheckResult> _checkSgtin(EPCParseResult parsed) async {
    final serial = parsed.serial;
    final gtin = parsed.gtin;
    if (serial == null || serial.isEmpty) {
      return const CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notTransitionable,
        blockReason: 'SGTIN is missing a serial number',
      );
    }

    final result = await _sgtinService.searchSGTINsAdvanced(
      gtinCode: gtin,
      serialNumber: serial,
      page: 0,
      size: 1,
    );
    final content = (result['content'] as List?)?.whereType<SGTIN>().toList() ??
        const <SGTIN>[];

    if (content.isEmpty) {
      return const CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notPreAllocated,
        blockReason: 'Serial not pre-allocated',
      );
    }

    final sgtin = content.first;
    return _sgtinStatusResult(sgtin);
  }

  CommissioningPoolCheckResult _sgtinStatusResult(SGTIN sgtin) {
    final status = sgtin.status;

    if (sgtin.commissioningEventId != null &&
        sgtin.commissioningEventId!.isNotEmpty) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.alreadyCommissioned,
        sourceStatus: status.name,
        blockReason:
            'Already commissioned (status ${status.name})',
      );
    }

    if (status == ItemStatus.RESERVED || status == ItemStatus.ALLOCATED) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.preReserved,
        sourceStatus: status.name,
        targetStatus: ItemStatus.COMMISSIONED.name,
      );
    }

    if (status == ItemStatus.COMMISSIONED) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.preReserved,
        sourceStatus: status.name,
        targetStatus: ItemStatus.COMMISSIONED.name,
      );
    }

    if (!sgtin_rules.canTransition(status, ItemStatus.COMMISSIONED)) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notTransitionable,
        sourceStatus: status.name,
        blockReason:
            'Cannot transition from ${status.name} to COMMISSIONED',
      );
    }

    return CommissioningPoolCheckResult(
      status: CommissioningSerialPoolStatus.notTransitionable,
      sourceStatus: status.name,
      blockReason: 'Serial is not eligible for commissioning',
    );
  }

  Future<CommissioningPoolCheckResult> _checkSscc(EPCParseResult parsed) async {
    final ssccCode = parsed.sscc;
    if (ssccCode == null || ssccCode.isEmpty) {
      return const CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notTransitionable,
        blockReason: 'SSCC code could not be resolved',
      );
    }

    try {
      final sscc = await _ssccService.getSSCCByCode(ssccCode);
      return _ssccStatusResult(sscc);
    } catch (_) {
      return const CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notPreAllocated,
        blockReason: 'Serial not pre-allocated',
      );
    }
  }

  CommissioningPoolCheckResult _ssccStatusResult(SSCC sscc) {
    final status = sscc.status;

    if (sscc.commissioningEventId != null &&
        sscc.commissioningEventId!.isNotEmpty) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.alreadyCommissioned,
        sourceStatus: status.name,
        blockReason: 'SSCC already commissioned',
      );
    }

    if (status == LogisticUnitStatus.ALLOCATED) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.preReserved,
        sourceStatus: status.name,
        targetStatus: LogisticUnitStatus.ACTIVE.name,
      );
    }

    if (status == LogisticUnitStatus.ACTIVE &&
        sscc.commissionedAt != null) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.alreadyCommissioned,
        sourceStatus: status.name,
        blockReason: 'SSCC already commissioned',
      );
    }

    if (status == LogisticUnitStatus.DRAFT) {
      return CommissioningPoolCheckResult(
        status: CommissioningSerialPoolStatus.notTransitionable,
        sourceStatus: status.name,
        blockReason: 'SSCC must be ALLOCATED before commissioning',
      );
    }

    return CommissioningPoolCheckResult(
      status: CommissioningSerialPoolStatus.notTransitionable,
      sourceStatus: status.name,
      blockReason: 'SSCC cannot be commissioned from ${status.name}',
    );
  }

  /// Returns a warning when a child SGTIN is not commissioned/active; null when OK.
  Future<String?> checkChildForAggregation(EPCParseResult parsed) async {
    if (parsed.type != EPCType.sgtin) {
      return 'Child EPC must be a SGTIN';
    }
    final check = await _checkSgtin(parsed);
    if (check.status == CommissioningSerialPoolStatus.notPreAllocated) {
      return 'Child SGTIN not found in serial pool';
    }
    if (check.status == CommissioningSerialPoolStatus.alreadyCommissioned) {
      return null;
    }
    final src = check.sourceStatus;
    if (src == 'COMMISSIONED' || src == 'ACTIVE' || src == 'RECEIVED') {
      return null;
    }
    if (check.status == CommissioningSerialPoolStatus.preReserved &&
        (src == 'RESERVED' || src == 'ALLOCATED')) {
      return 'Child SGTIN is not yet commissioned';
    }
    return check.blockReason ?? 'Child SGTIN is not eligible for aggregation';
  }
}
