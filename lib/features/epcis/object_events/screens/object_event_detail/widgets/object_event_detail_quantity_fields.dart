import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_detail/widgets/object_event_detail_field.dart';

class ObjectEventDetailQuantityFields extends StatelessWidget {
  const ObjectEventDetailQuantityFields({super.key, required this.quantity});
  final types.QuantityElement quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelEpcClass,
            value: quantity.epcClass,
            monospace: true,
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelQuantity,
            value: quantity.quantity.toString(),
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelUnitOfMeasure,
            value: quantity.uom,
          ),
        ],
      ),
    );
  }
}
