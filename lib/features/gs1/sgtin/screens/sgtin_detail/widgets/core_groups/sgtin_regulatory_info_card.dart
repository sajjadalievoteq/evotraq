import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class SgtinRegulatoryInfoCard extends StatelessWidget {
  const SgtinRegulatoryInfoCard({
    super.key,
    required this.borderColor,
    required this.isEditing,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.setFieldError,
  });

  final Color borderColor;
  final bool isEditing;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;
  final void Function(String, String?) setFieldError;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Regulatory Information',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1ValidatedField(
            controller: regulatoryMarketController,
            fieldName: 'regulatoryMarket',
            label: 'Regulatory Market',
            readOnly: !isEditing,
            setFieldError: setFieldError,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: regulatoryStatusController,
            fieldName: 'regulatoryStatus',
            label: 'Regulatory Status',
            readOnly: !isEditing,
            setFieldError: setFieldError,
          ),
        ],
      ),
    );
  }
}
