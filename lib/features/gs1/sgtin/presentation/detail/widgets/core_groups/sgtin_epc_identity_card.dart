import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinEpcIdentityCard extends StatelessWidget {
  const SgtinEpcIdentityCard({
    super.key,
    required this.sgtin,
    required this.borderColor,
  });

  final SGTIN sgtin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'EPC Identity',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SgtinInfoRow(
            'EPC URI (urn:epc:id:sgtin)',
            sgtin.epcUri ?? sgtin.computedEpcUri,
            monospace: true,
          ),
          if (sgtin.gs1DigitalLinkUri != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'GS1 Digital Link URI',
              sgtin.gs1DigitalLinkUri,
              monospace: true,
            ),
          ],
        ],
      ),
    );
  }
}
