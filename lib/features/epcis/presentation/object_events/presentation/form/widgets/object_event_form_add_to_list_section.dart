import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormListItemData {
  final String title;
  final String? subtitle;
  final VoidCallback? onRemove;

  const ObjectEventFormListItemData({
    required this.title,
    this.subtitle,
    this.onRemove,
  });
}

class ObjectEventFormAddToListSection extends StatelessWidget {
  final String title;
  final bool showTitleRequiredIndicator;
  /// When true, shows a title asterisk if any field in [requiredFieldNames] is mandatory.
  final List<String> requiredFieldNames;
  final String? action;
  final String? businessStep;
  final bool epcListEmpty;
  final bool quantityListEmpty;
  final List<String> epcList;
  final String listLabel;
  final int itemCount;
  final bool isViewOnly;
  final String emptyMessage;
  final Widget? inputArea;
  final VoidCallback? onAdd;
  final VoidCallback? onClearAll;
  final List<ObjectEventFormListItemData> items;
  final EdgeInsetsGeometry? margin;

  const ObjectEventFormAddToListSection({
    super.key,
    required this.title,
    this.showTitleRequiredIndicator = false,
    this.requiredFieldNames = const [],
    this.action,
    this.businessStep,
    this.epcListEmpty = false,
    this.quantityListEmpty = false,
    this.epcList = const [],
    required this.listLabel,
    required this.itemCount,
    required this.isViewOnly,
    required this.emptyMessage,
    required this.items,
    this.inputArea,
    this.onAdd,
    this.onClearAll,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final titleIsRequired = showTitleRequiredIndicator ||
        (requiredFieldNames.isNotEmpty &&
            ObjectEventFormMandatoryFields.groupHasRequiredField(
              fieldNames: requiredFieldNames,
              action: action,
              businessStep: businessStep,
              epcListEmpty: epcListEmpty,
              quantityListEmpty: quantityListEmpty,
              epcList: epcList,
            ));

    return ObjectEventFormSectionCard(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventFormSectionTitle(
            title: title,
            showRequiredIndicator: titleIsRequired,
          ),
          if (!isViewOnly && inputArea != null) ...[
            const SizedBox(height: 12.0),
            inputArea!,
            const SizedBox(height: 10.0),
            CustomElevatedButton(
              label: 'Add',
              onPressed: onAdd,
            ),
          ],
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$listLabel ($itemCount)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (!isViewOnly && onClearAll != null && itemCount > 0)
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!)
                        : null,
                    trailing: item.onRemove != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: item.onRemove,
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
