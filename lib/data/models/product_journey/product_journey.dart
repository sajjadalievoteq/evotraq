import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';

class ProductJourney {
  const ProductJourney({
    required this.identifier,
    required this.identifierType,
    required this.steps,
    this.productInfo,
    this.firstEventTime,
    this.lastEventTime,
    this.currentLocation,
    this.currentDisposition,
  });

  final String identifier;
  final String identifierType;
  final List<JourneyStep> steps;
  final ProductInfo? productInfo;
  final DateTime? firstEventTime;
  final DateTime? lastEventTime;
  final String? currentLocation;
  final String? currentDisposition;

  int get totalSteps => steps.length;

  Duration? get journeyDuration {
    if (firstEventTime != null && lastEventTime != null) {
      return lastEventTime!.difference(firstEventTime!);
    }
    return null;
  }

  int get locationsVisited =>
      steps.map((s) => s.locationGLN).where((g) => g != null).toSet().length;

  List<JourneyStep> get mappableSteps =>
      steps.where((s) => s.coordinates != null).toList();
}
