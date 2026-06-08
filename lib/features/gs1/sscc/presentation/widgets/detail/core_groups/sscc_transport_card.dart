import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccTransportCard extends StatelessWidget {
  const SsccTransportCard({
    super.key,
    required this.borderColor,
    required this.isReadOnly,
    required this.gsinController,
    required this.gincController,
    required this.poController,
    required this.carrierRoutingController,
    this.sscc,
  });

  final Color borderColor;
  final bool isReadOnly;
  final TextEditingController gsinController;
  final TextEditingController gincController;
  final TextEditingController poController;
  final TextEditingController carrierRoutingController;
  final SSCC? sscc;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Transport References',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isReadOnly) ...[
            SgtinInfoRow('GSIN (AI 402)', sscc?.gsin),
            const SizedBox(height: 12),
            SgtinInfoRow('GINC (AI 401)', sscc?.ginc),
            const SizedBox(height: 12),
            SgtinInfoRow('Purchase Order (AI 400)', sscc?.purchaseOrderNumber),
            const SizedBox(height: 12),
            SgtinInfoRow('Carrier Routing', sscc?.carrierRoutingCode),
          ] else ...[
            TextFormField(
              controller: gsinController,
              decoration: const InputDecoration(
                labelText: 'GSIN (AI 402)',
                border: OutlineInputBorder(),
              ),
              validator: validateGsin,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: gincController,
              decoration: const InputDecoration(
                labelText: 'GINC (AI 401)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: poController,
              decoration: const InputDecoration(
                labelText: 'Purchase Order (AI 400)',
                border: OutlineInputBorder(),
              ),
              validator: validatePurchaseOrderNumber,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: carrierRoutingController,
              decoration: const InputDecoration(
                labelText: 'Carrier Routing Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
