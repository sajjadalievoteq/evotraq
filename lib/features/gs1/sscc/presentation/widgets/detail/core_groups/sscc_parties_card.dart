import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';

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
          _partyField(
            context,
            label: 'Ship From GLN (AI 410)',
            selected: shipFromGln,
            storedCode: sscc?.shipFromGln,
            onChanged: onShipFromChanged,
          ),
          const SizedBox(height: 12),
          _partyField(
            context,
            label: 'Ship To GLN (AI 411)',
            selected: shipToGln,
            storedCode: sscc?.shipToGln,
            onChanged: onShipToChanged,
          ),
          const SizedBox(height: 12),
          _partyField(
            context,
            label: 'Bill To GLN (AI 412)',
            selected: billToGln,
            storedCode: sscc?.billToGln,
            onChanged: onBillToChanged,
          ),
          const SizedBox(height: 12),
          _partyField(
            context,
            label: 'Ship For GLN (AI 413)',
            selected: shipForGln,
            storedCode: sscc?.shipForGln,
            onChanged: onShipForChanged,
          ),
          const SizedBox(height: 12),
          _partyField(
            context,
            label: 'Current Custodian GLN',
            selected: custodianGln,
            storedCode: sscc?.currentCustodianGln,
            onChanged: onCustodianChanged,
          ),
        ],
      ),
    );
  }

  Widget _partyField(
    BuildContext context, {
    required String label,
    required GLN? selected,
    required String? storedCode,
    required ValueChanged<GLN?> onChanged,
  }) {
    if (isReadOnly) {
      final display = selected != null
          ? '${selected.glnCode} – ${selected.locationName}'
          : storedCode;
      return SgtinInfoRow(label, display);
    }

    return GLNSelector(
      label: label,
      hintText: 'Search and select $label',
      initialValue: selected,
      onChanged: onChanged,
      pickerCatalog: pickerCatalog,
    );
  }
}
