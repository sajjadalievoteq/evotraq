import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

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
        const SectionLabel(GlnUiConstants.sectionDigitalLocation),
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
        GtinValidatedField(
          controller: digitalAddressValueController,
          fieldName: 'digitalAddressValue',
          label: GlnUiConstants.labelDigitalAddressValue,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateDigitalAddressValueOptional,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GlnUiConstants.sectionDigitalLocation),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}
