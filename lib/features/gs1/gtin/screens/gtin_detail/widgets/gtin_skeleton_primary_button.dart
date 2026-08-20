import 'package:flutter/material.dart';

class GtinSkeletonPrimaryButton extends StatelessWidget {
  const GtinSkeletonPrimaryButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
