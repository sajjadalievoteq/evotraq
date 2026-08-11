import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ReferenceFieldPrefixIcon extends StatelessWidget {
  const ReferenceFieldPrefixIcon({
    required this.asset,
    required this.pad,
    super.key,
  });

  final String asset;
  final bool pad;

  @override
  Widget build(BuildContext context) {
    final icon = TraqIcon(asset);
    return pad
        ? Padding(padding: const EdgeInsets.only(left: 5), child: icon)
        : icon;
  }
}
