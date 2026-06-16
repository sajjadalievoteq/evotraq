import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_cbv_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_error_banner.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';

class ObjectEventFormBusinessContextSection extends StatelessWidget {
  final String? businessStep;
  final String? disposition;
  final List<String> bizStepValues;
  final List<String> dispositionValues;
  final Map<String, String> valueLabels;
  final bool isCbvLoading;
  final String? cbvLoadError;
  final EPCISVersion epcisVersion;
  final bool isViewOnly;
  final bool isBusinessStepMandatory;
  final bool isDispositionMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onBusinessStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  const ObjectEventFormBusinessContextSection({
    super.key,
    required this.businessStep,
    required this.disposition,
    required this.bizStepValues,
    required this.dispositionValues,
    required this.valueLabels,
    required this.isCbvLoading,
    this.cbvLoadError,
    required this.epcisVersion,
    required this.isViewOnly,
    required this.isBusinessStepMandatory,
    required this.isDispositionMandatory,
    required this.validation,
    required this.onBusinessStepChanged,
    required this.onDispositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titleIsRequired =
        isBusinessStepMandatory || isDispositionMandatory;

    return ObjectEventFormSectionCard(
      title: 'Business Context',
      showTitleRequiredIndicator: titleIsRequired,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCbvLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: AppLoadingIndicator()),
            )
          else if (cbvLoadError != null)
            ObjectEventFormErrorBanner(
              message: cbvLoadError!,
              onDismiss: () {},
            )
          else if (bizStepValues.isEmpty)
            const Text(
              'No business step options are available. Check your connection or contact support.',
              style: TextStyle(color: Colors.grey),
            )
          else ...[
            ObjectEventCbvDropdownField(
              fieldType: ObjectEventCbvFieldType.businessStep,
              fieldName: 'businessStep',
              label: 'Business Step',
              value: businessStep,
              standardValues: bizStepValues,
              valueLabels: valueLabels,
              isMandatory: isBusinessStepMandatory,
              isViewOnly: isViewOnly,
              validation: validation,
              epcisVersion: epcisVersion,
              onChanged: onBusinessStepChanged,
            ),
            const SizedBox(height: 16.0),
            ObjectEventCbvDropdownField(
              fieldType: ObjectEventCbvFieldType.disposition,
              fieldName: 'disposition',
              label: 'Disposition',
              value: disposition,
              standardValues: dispositionValues,
              valueLabels: valueLabels,
              isMandatory: isDispositionMandatory,
              isViewOnly: isViewOnly,
              validation: validation,
              epcisVersion: epcisVersion,
              onChanged: onDispositionChanged,
            ),
          ],
        ],
      ),
    );
  }
}
