import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class GtinFilterChips extends StatelessWidget {
  const GtinFilterChips({
    super.key,
    required this.showAdvancedFilters,
    required this.manufacturer,
    required this.status,
    required this.packagingLevel,
    required this.productName,
    required this.gtinCode,
    required this.onClearManufacturer,
    required this.onClearStatus,
    required this.onClearPackagingLevel,
    required this.onClearProductName,
    required this.onClearGtinCode,
  });

  final bool showAdvancedFilters;
  final String manufacturer;
  final String? status;
  final String? packagingLevel;
  final String productName;
  final String gtinCode;

  final VoidCallback onClearManufacturer;
  final VoidCallback onClearStatus;
  final VoidCallback onClearPackagingLevel;
  final VoidCallback onClearProductName;
  final VoidCallback onClearGtinCode;

  @override
  Widget build(BuildContext context) {
    if (showAdvancedFilters) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.spacing),
      child: Wrap(
        spacing: 8.0,
        children: [
          if (manufacturer.isNotEmpty)
            Chip(
              label: Text('Manufacturer: $manufacturer'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearManufacturer,
            ),
          if (status != null && status != 'All')
            Chip(
              label: Text('Status: $status'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearStatus,
            ),
          if (packagingLevel != null && packagingLevel != 'All')
            Chip(
              label: Text('Level: $packagingLevel'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearPackagingLevel,
            ),
          if (productName.isNotEmpty)
            Chip(
              label: Text('Product: $productName'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearProductName,
            ),
          if (gtinCode.isNotEmpty)
            Chip(
              label: Text('GTIN: $gtinCode'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearGtinCode,
            ),
        ],
      ),
    );
  }
}

