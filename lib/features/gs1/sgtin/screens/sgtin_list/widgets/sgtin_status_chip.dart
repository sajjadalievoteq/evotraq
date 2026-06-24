import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';

class SgtinStatusChip extends StatelessWidget {
  const SgtinStatusChip({super.key, required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (Color, String) _resolve(ItemStatus s) {
    switch (s) {
      case ItemStatus.RESERVED:
        return (const Color(0xFF78909C), 'Reserved');
      case ItemStatus.ALLOCATED:
        return (const Color(0xFF546E7A), 'Allocated');
      case ItemStatus.COMMISSIONED:
        return (const Color(0xFF2E7D32), 'Commissioned');
      case ItemStatus.ACTIVE:
        return (const Color(0xFF388E3C), 'Active');
      case ItemStatus.IN_TRANSIT:
        return (const Color(0xFF0277BD), 'In Transit');
      case ItemStatus.RECEIVED:
        return (const Color(0xFF00695C), 'Received');
      case ItemStatus.DISPENSED:
        return (const Color(0xFFE65100), 'Dispensed');
      case ItemStatus.RETURNED:
        return (const Color(0xFF6D4C41), 'Returned');
      case ItemStatus.RECALLED:
        return (const Color(0xFF880E4F), 'Recalled');
      case ItemStatus.STOLEN:
        return (const Color(0xFF4A148C), 'Stolen');
      case ItemStatus.EXPIRED:
        return (const Color(0xFFBF360C), 'Expired');
      case ItemStatus.DESTROYED:
        return (const Color(0xFF37474F), 'Destroyed');
      case ItemStatus.EXCEPTION:
        return (const Color(0xFFB71C1C), 'Exception');
    }
  }

  static Color colorFor(ItemStatus s) => _resolve(s).$1;
}
