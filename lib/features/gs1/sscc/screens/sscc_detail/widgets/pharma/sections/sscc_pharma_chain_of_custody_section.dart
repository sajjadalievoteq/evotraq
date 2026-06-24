import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaChainOfCustodySection extends StatelessWidget {
  const SsccPharmaChainOfCustodySection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.chainOfCustodyRequired,
    required this.onChainOfCustodyRequiredChanged,
    required this.requiresSignatureOnReceipt,
    required this.onRequiresSignatureOnReceiptChanged,
    required this.requiresPharmacistVerification,
    required this.onRequiresPharmacistVerificationChanged,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool chainOfCustodyRequired;
  final ValueChanged<bool> onChainOfCustodyRequiredChanged;
  final bool requiresSignatureOnReceipt;
  final ValueChanged<bool> onRequiresSignatureOnReceiptChanged;
  final bool requiresPharmacistVerification;
  final ValueChanged<bool> onRequiresPharmacistVerificationChanged;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Chain of Custody',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Chain of Custody Required'),
            subtitle: const Text('Track full custody chain'),
            value: chainOfCustodyRequired,
            onChanged: isEditing ? onChainOfCustodyRequiredChanged : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Requires Signature on Receipt'),
            subtitle: const Text('Must sign upon delivery'),
            value: requiresSignatureOnReceipt,
            onChanged: isEditing ? onRequiresSignatureOnReceiptChanged : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Requires Pharmacist Verification'),
            subtitle: const Text('Pharmacist must verify receipt'),
            value: requiresPharmacistVerification,
            onChanged:
                isEditing ? onRequiresPharmacistVerificationChanged : null,
          ),
        ],
      ),
    );
  }
}
