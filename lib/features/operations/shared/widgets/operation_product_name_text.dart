import 'package:flutter/material.dart';

class OperationProductNameText extends StatelessWidget {
  const OperationProductNameText({required this.name, super.key});

  final String? name;

  @override
  Widget build(BuildContext context) {
    if (name == null || name!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        name!,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
