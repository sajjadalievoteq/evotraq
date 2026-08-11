import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_party_field.dart';

class SsccPartiesCard extends StatelessWidget {
  const SsccPartiesCard({
    super.key,
    required this.borderColor,
    required this.isReadOnly,
    required this.shipFromGln,
    required this.shipToGln,
    required this.billToGln,
    required this.shipForGln,
    required this.custodianGln,
    required this.onShipFromChanged,
    required this.onShipToChanged,
    required this.onBillToChanged,
    required this.onShipForChanged,
    required this.onCustodianChanged,
    this.sscc,
    this.pickerCatalog,
  });

  final Color borderColor;
  final bool isReadOnly;
  final GLN? shipFromGln;
  final GLN? shipToGln;
  final GLN? billToGln;
  final GLN? shipForGln;
  final GLN? custodianGln;
  final ValueChanged<GLN?> onShipFromChanged;
  final ValueChanged<GLN?> onShipToChanged;
  final ValueChanged<GLN?> onBillToChanged;
  final ValueChanged<GLN?> onShipForChanged;
  final ValueChanged<GLN?> onCustodianChanged;
  final SSCC? sscc;
  final List<GLN>? pickerCatalog;

  @override
  Widget build(BuildContext context) {
    if (isReadOnly && sscc == null) {
      return const SizedBox.shrink();
    }

    return Gs1GroupCard(
      title: 'Parties & Locations',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SsccPartyField(
            isReadOnly: isReadOnly,
            pickerCatalog: pickerCatalog,
            label: 'Ship From GLN',
            selected: shipFromGln,
            storedCode: sscc?.shipFromGln,
            onChanged: onShipFromChanged,
          ),
          const SizedBox(height: 12),
          SsccPartyField(
            isReadOnly: isReadOnly,
            pickerCatalog: pickerCatalog,
            label: 'Ship To GLN',
            selected: shipToGln,
            storedCode: sscc?.shipToGln,
            onChanged: onShipToChanged,
          ),
          const SizedBox(height: 12),
          SsccPartyField(
            isReadOnly: isReadOnly,
            pickerCatalog: pickerCatalog,
            label: 'Bill To GLN',
            selected: billToGln,
            storedCode: sscc?.billToGln,
            onChanged: onBillToChanged,
          ),
          const SizedBox(height: 12),
          SsccPartyField(
            isReadOnly: isReadOnly,
            pickerCatalog: pickerCatalog,
            label: 'Ship For GLN',
            selected: shipForGln,
            storedCode: sscc?.shipForGln,
            onChanged: onShipForChanged,
          ),
          const SizedBox(height: 12),
          if (isReadOnly && sscc != null) ...[
            SgtinInfoRow(
              'Current Location',
              sscc!.currentLocation?.locationName ??
                  sscc!.currentLocationGln ??
                  'Unknown',
            ),
            const SizedBox(height: 12),
          ],
          SsccPartyField(
            isReadOnly: isReadOnly,
            pickerCatalog: pickerCatalog,
            label: 'Current Custodian GLN',
            selected: custodianGln,
            storedCode: sscc?.currentCustodianGln,
            onChanged: onCustodianChanged,
          ),
        ],
      ),
    );
  }
}
