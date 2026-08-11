import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

const _usStateOptions = <String, String>{
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'FL': 'Florida',
  'GA': 'Georgia',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'MT': 'Montana',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
  'DC': 'District of Columbia',
  'PR': 'Puerto Rico',
  'GU': 'Guam',
  'VI': 'Virgin Islands',
};

class GlnPharmaceuticalStateLicenseSection extends StatelessWidget {
  const GlnPharmaceuticalStateLicenseSection({
    required this.licenseNumberController,
    required this.licenseTypeController,
    required this.selectedState,
    required this.licenseExpiry,
    required this.isEditing,
    required this.onStateChanged,
    required this.onLicenseExpiryChanged,
    super.key,
  });

  final TextEditingController licenseNumberController;
  final TextEditingController licenseTypeController;
  final String? selectedState;
  final DateTime? licenseExpiry;
  final bool isEditing;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<DateTime?> onLicenseExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardStateProvincialLicense,
      iconAsset: AppAssets.iconBadge,
      children: [
        Row(
          children: [
            Expanded(
              child: GlnPharmaceuticalTextField(
                controller: licenseNumberController,
                label: GlnPharmaceuticalExtensionUiConstants.labelLicenseNumber,
                enabled: isEditing,
                maxLength: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedState,
                dropdownColor: context.colors.surface,
                decoration: const InputDecoration(
                  labelText:
                      GlnPharmaceuticalExtensionUiConstants.labelStateDropdown,
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(GlnExtensionSharedUiConstants.selectState),
                  ),
                  ..._usStateOptions.entries.map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    ),
                  ),
                ],
                onChanged: isEditing ? onStateChanged : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: licenseTypeController,
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseType,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalDateField(
          label: GlnPharmaceuticalExtensionUiConstants.labelLicenseExpiry,
          value: licenseExpiry,
          onChanged: isEditing ? onLicenseExpiryChanged : null,
        ),
      ],
    );
  }
}
