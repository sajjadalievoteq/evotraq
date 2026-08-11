import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';

class BarcodeTypeChip extends StatelessWidget {
  const BarcodeTypeChip({super.key, required this.type});

  final Gs1BarcodeType type;

  static const _labels = {
    Gs1BarcodeType.sgtin: 'SGTIN',
    Gs1BarcodeType.gtin: 'GTIN',
    Gs1BarcodeType.sscc: 'SSCC',
    Gs1BarcodeType.gln: 'GLN',
    Gs1BarcodeType.unknown: 'Unknown',
  };

  Color _color(BuildContext context) {
    final palette = OperationPalette.of(context);
    return switch (type) {
      Gs1BarcodeType.sgtin => Theme.of(context).colorScheme.primary,
      Gs1BarcodeType.gtin => palette.epcGtin,
      Gs1BarcodeType.sscc => palette.epcSscc,
      Gs1BarcodeType.gln => AppColorMapper.infoColor(context),
      Gs1BarcodeType.unknown => Theme.of(context).colorScheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Chip(
      label: Text(
        _labels[type] ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
