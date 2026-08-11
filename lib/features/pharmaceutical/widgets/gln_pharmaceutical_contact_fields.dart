import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalContactFields extends StatelessWidget {
  const GlnPharmaceuticalContactFields({
    required this.heading,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.isEditing,
    super.key,
  });

  final String heading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GlnPharmaceuticalTextField(
          controller: nameController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlnPharmaceuticalTextField(
                controller: emailController,
                label: GlnPharmaceuticalExtensionUiConstants.labelEmail,
                enabled: isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 255,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlnPharmaceuticalTextField(
                controller: phoneController,
                label: GlnPharmaceuticalExtensionUiConstants.labelPhone,
                enabled: isEditing,
                keyboardType: TextInputType.phone,
                maxLength: 50,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
