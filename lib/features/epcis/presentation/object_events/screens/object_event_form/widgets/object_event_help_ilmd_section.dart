import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_item.dart';

class ObjectEventHelpIlmdSection extends StatelessWidget {
  const ObjectEventHelpIlmdSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Instance/Lot Master Data (ILMD) is information that describes a specific instance or lot of products at the time of commissioning. ILMD is typically only included with ADD actions.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Examples of common ILMD attributes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ObjectEventHelpItem(
              title: 'lotNumber',
              description: 'A lot or batch number associated with the product.',
            ),
            ObjectEventHelpItem(
              title: 'expirationDate',
              description: 'The date when the product expires.',
            ),
            ObjectEventHelpItem(
              title: 'productionDate',
              description: 'The date when the product was manufactured.',
            ),
            ObjectEventHelpItem(
              title: 'bestBeforeDate',
              description:
                  'The date until which the product maintains its best quality.',
            ),
            ObjectEventHelpItem(
              title: 'serialLotNumber',
              description:
                  'A combined serial and lot number, for tracking both batch and individual items.',
            ),
          ],
        ),
      ),
    );
  }
}
