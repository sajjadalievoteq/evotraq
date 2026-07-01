import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

/// Label/value row for Return Receiving Detail cards.
class ReturnReceivingDetailInfoRow extends StatelessWidget {
  const ReturnReceivingDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SgtinInfoRow(label, value, valueColor: valueColor),
    );
  }
}

