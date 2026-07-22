import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';


class CommissioningEpcisPreviewCard extends StatelessWidget {
  const CommissioningEpcisPreviewCard({
    super.key,
    required this.items,
    required this.bizLocationGln,
    this.readPointGln,
    this.batchLot,
    this.expiryDate,
  });

  final List<CommissioningEpcItem> items;
  final String? bizLocationGln;
  final String? readPointGln;
  final String? batchLot;
  final DateTime? expiryDate;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final epcList = items.map((i) => i.epc).toList();
    final hasSgtin = items.any((i) => i.type == EPCType.sgtin);

    return Gs1GroupCard(
      title: 'EPCIS ObjectEvent Preview',
      outlineColor: outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('action', 'ADD'),
          _row('bizStep', 'urn:epcglobal:cbv:bizstep:commissioning'),
          _row('disposition', 'urn:epcglobal:cbv:disp:active'),
          if (bizLocationGln != null)
            _row('bizLocation', bizLocationGln!),
          if (readPointGln != null) _row('readPoint', readPointGln!),
          _row('epcList', '${epcList.length} EPC(s)'),
          ...epcList.take(5).map((e) => Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text(
                  e,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              )),
          if (epcList.length > 5)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text('… and ${epcList.length - 5} more'),
            ),
          if (hasSgtin && batchLot != null && batchLot!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('ILMD (pharma)', style: TextStyle(fontWeight: FontWeight.w600)),
            _row('lotNumber', batchLot!),
            if (expiryDate != null)
              _row('itemExpirationDate', expiryDate!.toIso8601String().split('T').first),
          ],
        ],
      ),
    );
  }

  Widget _row(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
