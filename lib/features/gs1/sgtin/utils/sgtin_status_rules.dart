library sgtin_status_rules;

import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';

const Map<ItemStatus, Set<ItemStatus>> allowedTransitionsMap = {
  ItemStatus.RESERVED: {
    ItemStatus.ALLOCATED,
  },
  ItemStatus.ALLOCATED: {
    ItemStatus.COMMISSIONED,
  },
  ItemStatus.COMMISSIONED: {
    ItemStatus.ACTIVE,
  },
  ItemStatus.ACTIVE: {
    ItemStatus.IN_TRANSIT,
    ItemStatus.DISPENSED,
    ItemStatus.DESTROYED,
    ItemStatus.RECALLED,
    ItemStatus.STOLEN,
    ItemStatus.EXPIRED,
    ItemStatus.EXCEPTION,
  },
  ItemStatus.IN_TRANSIT: {
    ItemStatus.RECEIVED,
    ItemStatus.ACTIVE,
    ItemStatus.DESTROYED,
    ItemStatus.RECALLED,
    ItemStatus.STOLEN,
    ItemStatus.EXCEPTION,
  },
  ItemStatus.RECEIVED: {
    ItemStatus.ACTIVE,
    ItemStatus.DISPENSED,
    ItemStatus.DESTROYED,
    ItemStatus.RECALLED,
    ItemStatus.EXCEPTION,
  },
  ItemStatus.DISPENSED: {
    ItemStatus.RETURNED,
  },
  ItemStatus.RETURNED: {
    ItemStatus.ACTIVE,
    ItemStatus.DESTROYED,
  },
  ItemStatus.RECALLED: {
    ItemStatus.DESTROYED,
    ItemStatus.EXCEPTION,
  },
  ItemStatus.EXCEPTION: {
    ItemStatus.ACTIVE,
    ItemStatus.DESTROYED,
  },
  ItemStatus.EXPIRED: {
    ItemStatus.DESTROYED,
  },
  ItemStatus.DESTROYED: {},
  ItemStatus.STOLEN: {},
};

Set<ItemStatus> allowedTransitions(ItemStatus from) {
  return allowedTransitionsMap[from] ?? const {};
}

bool canTransition(ItemStatus from, ItemStatus to) {
  return allowedTransitions(from).contains(to);
}

bool isTerminal(ItemStatus status) {
  return status == ItemStatus.DESTROYED || status == ItemStatus.STOLEN;
}

List<ItemStatus> selectableStatuses(ItemStatus current) {
  final transitions = allowedTransitions(current).toList();
  transitions.sort((a, b) => a.name.compareTo(b.name));
  return transitions;
}

String? validateTransition(ItemStatus from, ItemStatus to) {
  if (isTerminal(from)) {
    return 'Cannot change status: \'${friendlyLabel(from)}\' is a terminal state.';
  }
  if (!canTransition(from, to)) {
    return 'Transition from \'${friendlyLabel(from)}\' to \'${friendlyLabel(to)}\' is not permitted.';
  }
  return null;
}

const Map<ItemStatus, String> statusLabels = {
  ItemStatus.RESERVED:    'Reserved',
  ItemStatus.ALLOCATED:   'Allocated',
  ItemStatus.COMMISSIONED:'Commissioned',
  ItemStatus.ACTIVE:      'Active',
  ItemStatus.IN_TRANSIT:  'In Transit',
  ItemStatus.RECEIVED:    'Received',
  ItemStatus.DISPENSED:   'Dispensed',
  ItemStatus.RETURNED:    'Returned',
  ItemStatus.DESTROYED:   'Destroyed',
  ItemStatus.RECALLED:    'Recalled',
  ItemStatus.STOLEN:      'Stolen',
  ItemStatus.EXPIRED:     'Expired',
  ItemStatus.EXCEPTION:   'Exception',
};

String friendlyLabel(ItemStatus status) =>
    statusLabels[status] ?? status.name;

Color statusColor(ItemStatus status) {
  switch (status) {
    case ItemStatus.RESERVED:
      return Colors.grey.shade400;
    case ItemStatus.ALLOCATED:
      return Colors.blue.shade300;
    case ItemStatus.COMMISSIONED:
      return Colors.blue.shade600;
    case ItemStatus.ACTIVE:
      return Colors.green;
    case ItemStatus.IN_TRANSIT:
      return Colors.orange;
    case ItemStatus.RECEIVED:
      return Colors.teal;
    case ItemStatus.DISPENSED:
      return Colors.purple;
    case ItemStatus.RETURNED:
      return Colors.amber.shade700;
    case ItemStatus.DESTROYED:
      return Colors.red.shade800;
    case ItemStatus.RECALLED:
      return Colors.deepOrange;
    case ItemStatus.STOLEN:
      return Colors.red.shade900;
    case ItemStatus.EXPIRED:
      return Colors.brown;
    case ItemStatus.EXCEPTION:
      return Colors.red;
  }
}
