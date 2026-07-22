import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/journey_details_screen.dart';


class JourneySidebarContent extends StatelessWidget {
  const JourneySidebarContent({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    return JourneyDetailsContent(journey: journey);
  }
}
