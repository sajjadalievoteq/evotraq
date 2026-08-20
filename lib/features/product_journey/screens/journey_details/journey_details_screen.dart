import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey_details/journey_details_content.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';

class JourneyDetailsScreen extends StatelessWidget {
  const JourneyDetailsScreen({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    return JourneyDetailsContent(journey: journey);
  }
}
