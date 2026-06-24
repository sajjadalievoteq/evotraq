import 'package:flutter/material.dart';

class UserManagementUserInfoBadge extends StatelessWidget {
  const UserManagementUserInfoBadge({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 5, top: 1),
          decoration: BoxDecoration(
            color: valueColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          '$label: ',
          style: bodySmall?.copyWith(color: mutedColor),
        ),
        Text(
          value,
          style: bodySmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
