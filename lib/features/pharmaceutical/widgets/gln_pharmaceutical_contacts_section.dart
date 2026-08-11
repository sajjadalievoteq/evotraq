import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_contact_fields.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalContactsSection extends StatelessWidget {
  const GlnPharmaceuticalContactsSection({
    required this.pharmacistInChargeController,
    required this.picLicenseNumberController,
    required this.responsibleNameController,
    required this.responsibleEmailController,
    required this.responsiblePhoneController,
    required this.qualityNameController,
    required this.qualityEmailController,
    required this.qualityPhoneController,
    required this.regulatoryNameController,
    required this.regulatoryEmailController,
    required this.regulatoryPhoneController,
    required this.isEditing,
    super.key,
  });

  final TextEditingController pharmacistInChargeController;
  final TextEditingController picLicenseNumberController;
  final TextEditingController responsibleNameController;
  final TextEditingController responsibleEmailController;
  final TextEditingController responsiblePhoneController;
  final TextEditingController qualityNameController;
  final TextEditingController qualityEmailController;
  final TextEditingController qualityPhoneController;
  final TextEditingController regulatoryNameController;
  final TextEditingController regulatoryEmailController;
  final TextEditingController regulatoryPhoneController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardContactInformation,
      iconAsset: AppAssets.iconPhone,
      children: [
        const Text(
          GlnPharmaceuticalExtensionUiConstants.headingPharmacistInCharge,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GlnPharmaceuticalTextField(
          controller: pharmacistInChargeController,
          label: GlnPharmaceuticalExtensionUiConstants.labelName,
          enabled: isEditing,
          maxLength: 200,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: picLicenseNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseNumber,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalContactFields(
          heading:
              GlnPharmaceuticalExtensionUiConstants.headingResponsiblePerson,
          nameController: responsibleNameController,
          emailController: responsibleEmailController,
          phoneController: responsiblePhoneController,
          isEditing: isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalContactFields(
          heading: GlnPharmaceuticalExtensionUiConstants.headingQualityContact,
          nameController: qualityNameController,
          emailController: qualityEmailController,
          phoneController: qualityPhoneController,
          isEditing: isEditing,
        ),
        const SizedBox(height: 16),
        GlnPharmaceuticalContactFields(
          heading:
              GlnPharmaceuticalExtensionUiConstants.headingRegulatoryContact,
          nameController: regulatoryNameController,
          emailController: regulatoryEmailController,
          phoneController: regulatoryPhoneController,
          isEditing: isEditing,
        ),
      ],
    );
  }
}
