import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';

class CommissioningLocationCard extends StatelessWidget {
  const CommissioningLocationCard({
    super.key,
    required this.commissioningLocationGLN,
    required this.locationError,
    required this.onLocationChanged,
  });

  final GLN? commissioningLocationGLN;
  final String? locationError;
  final ValueChanged<GLN?> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Commissioning Location',
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: OperationGlnSelector(
        label: 'Location GLN *',
        gln: commissioningLocationGLN,
        onChanged: onLocationChanged,
        hintText: 'Select commissioning location',
        errorText: locationError,
      ),
    );
  }
}
