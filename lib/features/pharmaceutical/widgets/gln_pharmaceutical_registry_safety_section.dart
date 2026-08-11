import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalRegistrySafetySection extends StatelessWidget {
  const GlnPharmaceuticalRegistrySafetySection({
    required this.brandsyncPartyIdController,
    required this.tatmeenPartyCodeController,
    required this.mahTargetMarketsController,
    required this.mahRegistrationNumberController,
    required this.licensedAgentAuthorisationController,
    required this.authorisedPrincipalMahGlnsController,
    required this.pharmacovigilanceEmailController,
    required this.recallContactEmailController,
    required this.recallContactPhoneController,
    required this.epcisCaptureEndpointUrlController,
    required this.mahQualificationIndicator,
    required this.isEditing,
    required this.onMahQualificationChanged,
    super.key,
  });

  final TextEditingController brandsyncPartyIdController;
  final TextEditingController tatmeenPartyCodeController;
  final TextEditingController mahTargetMarketsController;
  final TextEditingController mahRegistrationNumberController;
  final TextEditingController licensedAgentAuthorisationController;
  final TextEditingController authorisedPrincipalMahGlnsController;
  final TextEditingController pharmacovigilanceEmailController;
  final TextEditingController recallContactEmailController;
  final TextEditingController recallContactPhoneController;
  final TextEditingController epcisCaptureEndpointUrlController;
  final bool mahQualificationIndicator;
  final bool isEditing;
  final ValueChanged<bool> onMahQualificationChanged;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmaceutical Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: GlnPharmaceuticalExtensionUiConstants.sectionUaeRegistry,
          outlineColor: outline,
          child: Row(
            children: [
              Expanded(
                child: GlnPharmaceuticalTextField(
                  controller: brandsyncPartyIdController,
                  label: GlnPharmaceuticalExtensionUiConstants
                      .labelBrandSyncPartyId,
                  enabled: isEditing,
                  maxLength: 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlnPharmaceuticalTextField(
                  controller: tatmeenPartyCodeController,
                  label: GlnPharmaceuticalExtensionUiConstants
                      .labelTatmeenPartyCode,
                  enabled: isEditing,
                  maxLength: 50,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: GlnPharmaceuticalExtensionUiConstants.sectionMahTargetMarkets,
          outlineColor: outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlnPharmaceuticalSwitch(
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelMahQualificationIndicator,
                value: mahQualificationIndicator,
                onChanged: isEditing ? onMahQualificationChanged : null,
              ),
              const SizedBox(height: 12),
              GlnPharmaceuticalTextField(
                controller: mahTargetMarketsController,
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelMahTargetMarketsIso,
                hint: GlnPharmaceuticalExtensionUiConstants
                    .hintMahTargetMarketsIso,
                enabled: isEditing,
                maxLength: 200,
              ),
              const SizedBox(height: 12),
              GlnPharmaceuticalTextField(
                controller: mahRegistrationNumberController,
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelMahRegulatoryRegistrationNumber,
                enabled: isEditing,
                maxLength: 50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: GlnPharmaceuticalExtensionUiConstants.sectionLicensedAgent,
          outlineColor: outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlnPharmaceuticalTextField(
                controller: licensedAgentAuthorisationController,
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelLicensedAgentAuthorisationNumber,
                enabled: isEditing,
                maxLength: 50,
              ),
              const SizedBox(height: 12),
              GlnPharmaceuticalTextField(
                controller: authorisedPrincipalMahGlnsController,
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelAuthorisedPrincipalMahGlns,
                hint: GlnPharmaceuticalExtensionUiConstants
                    .hintAuthorisedPrincipalMahGlns,
                enabled: isEditing,
                maxLength: 500,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: GlnPharmaceuticalExtensionUiConstants.sectionPharmacovigilance,
          outlineColor: outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlnPharmaceuticalTextField(
                controller: pharmacovigilanceEmailController,
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelPharmacovigilanceEmail,
                enabled: isEditing,
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlnPharmaceuticalTextField(
                      controller: recallContactEmailController,
                      label: GlnPharmaceuticalExtensionUiConstants
                          .labelRecallContactEmail,
                      enabled: isEditing,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 254,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlnPharmaceuticalTextField(
                      controller: recallContactPhoneController,
                      label: GlnPharmaceuticalExtensionUiConstants
                          .labelRecallContactPhone,
                      enabled: isEditing,
                      keyboardType: TextInputType.phone,
                      maxLength: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Gs1GroupCard(
          title: GlnPharmaceuticalExtensionUiConstants.sectionEpicsDataExchange,
          outlineColor: outline,
          child: GlnPharmaceuticalTextField(
            controller: epcisCaptureEndpointUrlController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelEpicsCaptureEndpointUrl,
            hint: GlnPharmaceuticalExtensionUiConstants.hintHttpsUrl,
            enabled: isEditing,
            keyboardType: TextInputType.url,
            maxLength: 500,
          ),
        ),
      ],
    );
  }
}
