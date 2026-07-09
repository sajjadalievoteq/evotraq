import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';

/// One EPC queued for commissioning with pool validation metadata.
class CommissioningEpcItem {
  const CommissioningEpcItem({
    required this.parsed,
    this.poolStatus = CommissioningSerialPoolStatus.checking,
    this.sourceStatus,
    this.targetStatus,
    this.blockReason,
    this.isManualEntry = false,
    this.childEpcs = const [],
  });

  final EPCParseResult parsed;
  final CommissioningSerialPoolStatus poolStatus;
  final String? sourceStatus;
  final String? targetStatus;
  final String? blockReason;
  final bool isManualEntry;
  final List<String> childEpcs;

  String get epc => parsed.epc;
  EPCType get type => parsed.type;

  String get displayKey =>
      parsed.serial ?? parsed.sscc ?? parsed.gtin ?? parsed.epc;

  CommissioningEpcItem copyWith({
    EPCParseResult? parsed,
    CommissioningSerialPoolStatus? poolStatus,
    String? sourceStatus,
    String? targetStatus,
    String? blockReason,
    bool? isManualEntry,
    List<String>? childEpcs,
  }) {
    return CommissioningEpcItem(
      parsed: parsed ?? this.parsed,
      poolStatus: poolStatus ?? this.poolStatus,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      targetStatus: targetStatus ?? this.targetStatus,
      blockReason: blockReason ?? this.blockReason,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      childEpcs: childEpcs ?? this.childEpcs,
    );
  }
}
