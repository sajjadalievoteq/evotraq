import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';

/// Reusable GLN + facility rows for operation detail location cards.
class OperationGlnLocationRows extends StatelessWidget {
  const OperationGlnLocationRows({
    super.key,
    required this.glnLabel,
    required this.glnCode,
    this.location,
    this.facilityLabel = 'Facility',
    this.cityLabel = 'City',
    this.showDirectionAfter = false,
    this.directionLabel = 'Direction',
    this.directionValue = 'From -> To',
  });

  final String glnLabel;
  final String? glnCode;
  final OperationGlnDisplay? location;
  final String facilityLabel;
  final String cityLabel;
  final bool showDirectionAfter;
  final String directionLabel;
  final String directionValue;

  @override
  Widget build(BuildContext context) {
    final name = location?.locationName;
    final city = location?.city;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (glnCode != null && glnCode!.isNotEmpty)
          _Row(label: glnLabel, value: glnCode!, copyable: true),
        if (name != null && name.isNotEmpty)
          _Row(label: facilityLabel, value: name),
        if (city != null && city.isNotEmpty) _Row(label: cityLabel, value: city),
        if (showDirectionAfter)
          _Row(label: directionLabel, value: directionValue),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontFamily: copyable ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
