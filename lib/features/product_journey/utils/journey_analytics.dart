import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';

abstract final class JourneyAnalytics {
  static List<Duration> _transitDurations(ProductJourney journey) {
    final steps = journey.steps;
    if (steps.length < 2) return const [];

    final durations = <Duration>[];
    for (var i = 0; i < steps.length - 1; i++) {
      final d = steps[i + 1].eventTime.difference(steps[i].eventTime);
      if (d.inMinutes > 0) durations.add(d);
    }
    return durations;
  }

  static Duration? longestTransit(ProductJourney journey) {
    final durations = _transitDurations(journey);
    if (durations.isEmpty) return null;
    return durations.reduce((a, b) => a > b ? a : b);
  }

  static Duration? averageTransit(ProductJourney journey) {
    final durations = _transitDurations(journey);
    if (durations.isEmpty) return null;
    final total = durations.fold<int>(0, (sum, d) => sum + d.inMinutes);
    return Duration(minutes: total ~/ durations.length);
  }

  static int shipmentCount(ProductJourney journey) =>
      journey.steps.where((s) => JourneyEventFilter.shipping.matches(s)).length;

  static int aggregationCount(ProductJourney journey) =>
      journey.steps.where((s) => JourneyEventFilter.aggregation.matches(s)).length;

  static int businessPartnerCount(ProductJourney journey) => journey.steps
      .map((s) => s.locationGLN ?? s.locationName)
      .where((v) => v != null && v.isNotEmpty)
      .toSet()
      .length;

  static int countryCount(ProductJourney journey) => journey.steps
      .map(_countryFromStep)
      .where((c) => c != null && c.isNotEmpty)
      .toSet()
      .length;

  static int organizationCount(ProductJourney journey) =>
      businessPartnerCount(journey);

  static String? _countryFromStep(JourneyStep step) {
    final address = step.locationAddress;
    if (address == null || address.isEmpty) return null;
    final parts = address.split(',').map((p) => p.trim()).toList();
    if (parts.isEmpty) return null;
    return parts.last;
  }

  static JourneyStep? lastStep(ProductJourney journey) =>
      journey.steps.isEmpty ? null : journey.steps.last;
}
