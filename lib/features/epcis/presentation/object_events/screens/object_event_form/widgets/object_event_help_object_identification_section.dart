import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_item.dart';

class ObjectEventHelpObjectIdentificationSection extends StatelessWidget {
  const ObjectEventHelpObjectIdentificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ObjectEventHelpItem(
              title: 'EPCs (Instance-Level)',
              description:
                  'Electronic Product Codes that uniquely identify individual items. Use this for serialized items like SGTINs (Serialized GTINs). Format example: https://id.gs1.org/01/10614141073464/21/2017',
            ),
            ObjectEventHelpItem(
              title: 'EPC Classes (Class-Level)',
              description:
                  'Identifies a class of objects without serialization. Used for product classes. Format example: urn:epc:idpat:sgtin:0614141.107346.*',
            ),
            ObjectEventHelpItem(
              title: 'Quantities',
              description:
                  'Used for class-level identification with a specific quantity and unit of measure. Useful when tracking quantities of non-serialized products.',
            ),
          ],
        ),
      ),
    );
  }
}
