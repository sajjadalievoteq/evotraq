import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/core_groups/gtin_packed_into_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_label_value_row.dart';

class GtinSupplyChainCard extends StatelessWidget {
  const GtinSupplyChainCard({super.key, required this.gtin});

  final GTIN gtin;

  @override
  Widget build(BuildContext context) {
    final locationLabel =
        gtin.currentLocation?.locationName ??
        gtin.currentLocationName ??
        gtin.currentLocationGln ??
        gtin.currentLocation?.glnCode ??
        'Unknown';
    final packedIn = gtin.currentPackedInEpc?.trim();
    final hasPackedIn = packedIn != null && packedIn.isNotEmpty;

    return Gs1GroupCard(
      title: 'Supply Chain Context',
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1LabelValueRow(
            label: 'Current Location',
            value: locationLabel,
            monospace: false,
          ),
          if (gtin.currentLocation?.glnCode != null &&
              gtin.currentLocation!.locationName != locationLabel)
            Gs1LabelValueRow(
              label: 'Location GLN',
              value: gtin.currentLocation!.glnCode,
            ),
          if (hasPackedIn) GtinPackedIntoRow(epc: packedIn),
        ],
      ),
    );
  }
}
