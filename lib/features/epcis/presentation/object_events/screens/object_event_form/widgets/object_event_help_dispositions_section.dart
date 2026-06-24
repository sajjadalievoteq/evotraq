import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_item.dart';

class ObjectEventHelpDispositionsSection extends StatelessWidget {
  const ObjectEventHelpDispositionsSection({super.key});

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
              'Common Dispositions for Object Events:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ObjectEventHelpItem(
              title: 'active',
              description: 'The object is in operational use.',
            ),
            ObjectEventHelpItem(
              title: 'available',
              description: 'The object is available for future processing.',
            ),
            ObjectEventHelpItem(
              title: 'in_progress',
              description: 'The object is undergoing processing.',
            ),
            ObjectEventHelpItem(
              title: 'in_transit',
              description:
                  'The object is in the process of being transported from one location to another.',
            ),
            ObjectEventHelpItem(
              title: 'retail_sold',
              description:
                  'The object has been sold at retail to the end consumer.',
            ),
            ObjectEventHelpItem(
              title: 'expired',
              description: 'The object has expired.',
            ),
            ObjectEventHelpItem(
              title: 'recalled',
              description:
                  'The object has been recalled by the manufacturer, government, etc.',
            ),
            ObjectEventHelpItem(
              title: 'damaged',
              description: 'The object has been damaged during handling.',
            ),
            ObjectEventHelpItem(
              title: 'destroyed',
              description: 'The object has been permanently destroyed.',
            ),
          ],
        ),
      ),
    );
  }
}
