import 'package:flutter/material.dart';

class AuthHeroSubtitle extends StatelessWidget {
  const AuthHeroSubtitle({
    super.key,
    required this.subtitle,
    required this.color,
  });

  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(fontSize: 16, color: color),
      textAlign: TextAlign.center,
    );
  }
}
