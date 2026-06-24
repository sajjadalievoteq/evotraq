import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_quantity_row_controllers.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_business_context_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_business_data_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_child_items_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_destination_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_error_banner.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_event_details_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_location_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_parent_container_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_source_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_rules_panel.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validation_error_widget.dart';

class AggregationEventFormBody extends StatelessWidget {
  const AggregationEventFormBody({
    super.key,
    required this.formKey,
    required this.validationErrors,
    required this.onDismissValidationErrors,
    required this.errorMessage,
    required this.onDismissErrorMessage,
    required this.selectedAction,
    required this.onActionChanged,
    required this.eventTime,
    required this.onSelectEventTime,
    required this.businessStep,
    required this.disposition,
    required this.onBizStepChanged,
    required this.onDispositionChanged,
    required this.initialParentEpc,
    required this.onParentEpcChanged,
    required this.useQuantityList,
    required this.onUseQuantityListChanged,
    required this.childEpcControllers,
    required this.onAddChildEpc,
    required this.onRemoveChildEpc,
    required this.onScanAndAddChildEpc,
    required this.quantityRows,
    required this.onAddQuantityRow,
    required this.onRemoveQuantityRow,
    required this.locationGLN,
    required this.locationGlnError,
    required this.onLocationChanged,
    required this.sourceListControllers,
    required this.onAddSourceEntry,
    required this.onRemoveSourceEntry,
    required this.destinationListControllers,
    required this.onAddDestinationEntry,
    required this.onRemoveDestinationEntry,
    required this.bizDataControllers,
    required this.onAddBizDataField,
    required this.onRemoveBizDataField,
    required this.onSave,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final List<dynamic> validationErrors;
  final VoidCallback onDismissValidationErrors;
  final String? errorMessage;
  final VoidCallback onDismissErrorMessage;
  final String selectedAction;
  final ValueChanged<String?> onActionChanged;
  final DateTime eventTime;
  final VoidCallback onSelectEventTime;
  final String? businessStep;
  final String? disposition;
  final ValueChanged<String?> onBizStepChanged;
  final ValueChanged<String?> onDispositionChanged;
  final String? initialParentEpc;
  final ValueChanged<String> onParentEpcChanged;
  final bool useQuantityList;
  final ValueChanged<bool> onUseQuantityListChanged;
  final List<TextEditingController> childEpcControllers;
  final VoidCallback onAddChildEpc;
  final ValueChanged<int> onRemoveChildEpc;
  final VoidCallback onScanAndAddChildEpc;
  final List<AggregationEventFormQuantityRowControllers> quantityRows;
  final VoidCallback onAddQuantityRow;
  final void Function(int index, AggregationEventFormQuantityRowControllers row)
      onRemoveQuantityRow;
  final GLN? locationGLN;
  final String? locationGlnError;
  final ValueChanged<GLN?> onLocationChanged;
  final List<MapEntry<TextEditingController, TextEditingController>>
      sourceListControllers;
  final VoidCallback onAddSourceEntry;
  final ValueChanged<int> onRemoveSourceEntry;
  final List<MapEntry<TextEditingController, TextEditingController>>
      destinationListControllers;
  final VoidCallback onAddDestinationEntry;
  final ValueChanged<int> onRemoveDestinationEntry;
  final List<MapEntry<TextEditingController, TextEditingController>>
      bizDataControllers;
  final VoidCallback onAddBizDataField;
  final ValueChanged<int> onRemoveBizDataField;
  final VoidCallback onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.padding,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (validationErrors.isNotEmpty) ...[
              ValidationErrorWidget(
                validationErrors: validationErrors,
                onDismiss: onDismissValidationErrors,
              ),
              const SizedBox(height: 16),
            ],
            if (errorMessage != null) ...[
              AggregationEventFormErrorBanner(
                message: errorMessage!,
                onDismiss: onDismissErrorMessage,
              ),
              const SizedBox(height: 16),
            ],
            const AggregationPharmaRulesPanel(),
            const SizedBox(height: 16),
            AggregationEventFormEventDetailsSection(
              selectedAction: selectedAction,
              eventTime: eventTime,
              onActionChanged: onActionChanged,
              onSelectEventTime: onSelectEventTime,
            ),
            const SizedBox(height: 16),
            AggregationEventFormBusinessContextSection(
              action: selectedAction,
              businessStep: businessStep,
              disposition: disposition,
              onBizStepChanged: onBizStepChanged,
              onDispositionChanged: onDispositionChanged,
            ),
            const SizedBox(height: 16),
            AggregationEventFormParentContainerSection(
              selectedAction: selectedAction,
              initialParentEpc: initialParentEpc,
              onParentEpcChanged: onParentEpcChanged,
            ),
            const SizedBox(height: 16),
            AggregationEventFormChildItemsSection(
              selectedAction: selectedAction,
              useQuantityList: useQuantityList,
              onUseQuantityListChanged: onUseQuantityListChanged,
              childEpcControllers: childEpcControllers,
              onAddChildEpc: onAddChildEpc,
              onRemoveChildEpc: onRemoveChildEpc,
              onScanAndAddChildEpc: onScanAndAddChildEpc,
              quantityRows: quantityRows,
              onAddQuantityRow: onAddQuantityRow,
              onRemoveQuantityRow: onRemoveQuantityRow,
            ),
            const SizedBox(height: 16),
            AggregationEventFormLocationSection(
              locationGLN: locationGLN,
              locationGlnError: locationGlnError,
              onLocationChanged: onLocationChanged,
            ),
            const SizedBox(height: 16),
            AggregationEventFormSourceListSection(
              sourceListControllers: sourceListControllers,
              onAddSourceEntry: onAddSourceEntry,
              onRemoveSourceEntry: onRemoveSourceEntry,
            ),
            const SizedBox(height: 16),
            AggregationEventFormDestinationListSection(
              destinationListControllers: destinationListControllers,
              onAddDestinationEntry: onAddDestinationEntry,
              onRemoveDestinationEntry: onRemoveDestinationEntry,
            ),
            const SizedBox(height: 16),
            AggregationEventFormBusinessDataSection(
              bizDataControllers: bizDataControllers,
              onAddBizDataField: onAddBizDataField,
              onRemoveBizDataField: onRemoveBizDataField,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              label: 'Create Aggregation Event',
              onPressed: onSave,
              isLoading: isLoading,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
