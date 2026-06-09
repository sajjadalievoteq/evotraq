
import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

const Map<LogisticUnitStatus, Set<LogisticUnitStatus>> ssccAllowedTransitions = {
  LogisticUnitStatus.DRAFT: {
    LogisticUnitStatus.ALLOCATED,
    LogisticUnitStatus.VOIDED,
  },
  LogisticUnitStatus.ALLOCATED: {
    LogisticUnitStatus.ACTIVE,
    LogisticUnitStatus.VOIDED,
  },
  LogisticUnitStatus.ACTIVE: {
    LogisticUnitStatus.IN_TRANSIT,
  },
  LogisticUnitStatus.IN_TRANSIT: {
    LogisticUnitStatus.RECEIVED,
  },
  LogisticUnitStatus.RECEIVED: {
    LogisticUnitStatus.DECOMMISSIONED,
  },
  LogisticUnitStatus.DECOMMISSIONED: {},
  LogisticUnitStatus.VOIDED: {},
};

Set<LogisticUnitStatus> allowedTransitions(LogisticUnitStatus from) {
  return ssccAllowedTransitions[from] ?? const {};
}

bool canTransition(LogisticUnitStatus from, LogisticUnitStatus to) {
  if (from == to) return true;
  return allowedTransitions(from).contains(to);
}

bool isTerminal(LogisticUnitStatus status) {
  return status == LogisticUnitStatus.DECOMMISSIONED ||
      status == LogisticUnitStatus.VOIDED;
}

List<LogisticUnitStatus> selectableStatuses(
  LogisticUnitStatus current, {
  List<String>? serverTransitions,
}) {
  if (serverTransitions != null && serverTransitions.isNotEmpty) {
    final parsed = <LogisticUnitStatus>{};
    for (final name in serverTransitions) {
      final s = SSCC.parseStatus(name);
      if (s != current) parsed.add(s);
    }
    final list = parsed.toList()..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
  final transitions = allowedTransitions(current).toList();
  transitions.sort((a, b) => a.name.compareTo(b.name));
  return transitions;
}

String? validateTransition(LogisticUnitStatus from, LogisticUnitStatus to) {
  if (from == to) return null;
  if (isTerminal(from)) {
    return 'Cannot change status: \'${friendlyLabel(from)}\' is terminal.';
  }
  if (!canTransition(from, to)) {
    return 'Transition from \'${friendlyLabel(from)}\' to \'${friendlyLabel(to)}\' is not permitted.';
  }
  return null;
}

const Map<LogisticUnitStatus, String> statusLabels = {
  LogisticUnitStatus.DRAFT: 'Draft',
  LogisticUnitStatus.ALLOCATED: 'Allocated',
  LogisticUnitStatus.ACTIVE: 'Active',
  LogisticUnitStatus.IN_TRANSIT: 'In Transit',
  LogisticUnitStatus.RECEIVED: 'Received',
  LogisticUnitStatus.DECOMMISSIONED: 'Decommissioned',
  LogisticUnitStatus.VOIDED: 'Voided',
};

String friendlyLabel(LogisticUnitStatus status) =>
    statusLabels[status] ?? status.name;

Color statusColor(LogisticUnitStatus status) {
  switch (status) {
    case LogisticUnitStatus.DRAFT:
      return Colors.blueGrey;
    case LogisticUnitStatus.ALLOCATED:
      return Colors.blue.shade400;
    case LogisticUnitStatus.ACTIVE:
      return Colors.green.shade700;
    case LogisticUnitStatus.IN_TRANSIT:
      return Colors.orange.shade700;
    case LogisticUnitStatus.RECEIVED:
      return Colors.teal.shade700;
    case LogisticUnitStatus.DECOMMISSIONED:
      return Colors.brown.shade600;
    case LogisticUnitStatus.VOIDED:
      return Colors.red.shade800;
  }
}

const Map<UnitType, String> unitTypeLabels = {
  UnitType.PALLET: 'Pallet',
  UnitType.CASE: 'Case',
  UnitType.CARTON: 'Carton',
  UnitType.TOTE: 'Tote',
  UnitType.CONTAINER: 'Container',
  UnitType.DRUM: 'Drum',
  UnitType.AIR_ULD: 'Air ULD',
  UnitType.PARCEL: 'Parcel',
  UnitType.ROLL_CAGE: 'Roll Cage',
  UnitType.OTHER: 'Other',
};

String friendlyUnitTypeLabel(UnitType type) =>
    unitTypeLabels[type] ?? type.name;
