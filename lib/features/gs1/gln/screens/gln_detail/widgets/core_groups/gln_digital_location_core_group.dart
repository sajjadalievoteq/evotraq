import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class GlnDigitalLocationCoreGroup extends StatelessWidget {
  const GlnDigitalLocationCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.setFieldError,
    required this.readOnly,
    required this.digitalAddressType,
    required this.onDigitalAddressTypeChanged,
    required this.digitalAddressValueController,
  });

  final bool showFieldSkeleton;
  final GlnFormSetFieldError setFieldError;
  final bool readOnly;
  final String digitalAddressType;
  final ValueChanged<String?> onDigitalAddressTypeChanged;
  final TextEditingController digitalAddressValueController;

  @override
  Widget build(BuildContext context) {
    final isEditing = !readOnly;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(digitalAddressType),
          initialValue: digitalAddressType,
          decoration: const InputDecoration(
            labelText: GlnUiConstants.labelDigitalAddressType,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeEdiGateway,
              child: Text(GlnUiConstants.digitalTypeEdiGatewayLabel),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeUrl,
              child: Text(GlnUiConstants.digitalTypeUrl),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeAs2,
              child: Text(GlnUiConstants.digitalTypeAs2Label),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeSftp,
              child: Text(GlnUiConstants.digitalTypeSftp),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeApi,
              child: Text(GlnUiConstants.digitalTypeApi),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeEmail,
              child: Text(GlnUiConstants.digitalTypeEmailLabel),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.digitalTypeOther,
              child: Text(GlnUiConstants.digitalTypeOtherLabel),
            ),
          ],
          onChanged: isEditing ? onDigitalAddressTypeChanged : null,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: digitalAddressValueController,
          fieldName: 'digitalAddressValue',
          label: GlnUiConstants.labelDigitalAddressValue,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateDigitalAddressValueOptional,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GlnUiConstants.sectionDigitalLocation,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
      child: body,
    );
  }
}
