import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.bytes,
    this.firstName,
    this.backgroundColor,
    this.initialTextStyle,
    this.overlay,
  });

  final double radius;
  final Uint8List? bytes;
  final String? firstName;
  final Color? backgroundColor;
  final TextStyle? initialTextStyle;
  final Widget? overlay;

  String _initial() {
    final v = (firstName ?? '').trim();
    if (v.isEmpty) return 'U';
    return v.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasBytes = bytes != null && bytes!.isNotEmpty;
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: bg,
          backgroundImage: hasBytes ? MemoryImage(bytes!) : null,
          child: hasBytes
              ? null
              : Text(
                  _initial(),
                  style: initialTextStyle ??
                      TextStyle(
                        fontSize: radius * 0.8,
                        color: Colors.white,
                      ),
                ),
        ),
        overlay ?? const SizedBox.shrink(),
      ],
    );
  }
}

