import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
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

  factory ProductJourney.fromBackendJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List<dynamic>?)
            ?.map(
              (s) => JourneyStep.fromBackendStepJson(
                Map<String, dynamic>.from(s as Map),
              ),
            )
            .toList() ??
        const <JourneyStep>[];

    final resolvedInfo = json['resolvedInfo'];

    return ProductJourney(
      identifier: json['identifier']?.toString() ?? '',
      identifierType: json['identifierType']?.toString() ?? 'EPC',
      steps: steps,
      productInfo: resolvedInfo is Map<String, dynamic>
          ? ProductInfo.fromResolvedJson(resolvedInfo)
          : null,
      firstEventTime: json['firstEventTime'] != null
          ? DateTime.tryParse(json['firstEventTime'].toString())
          : (steps.isNotEmpty ? steps.first.eventTime : null),
      lastEventTime: json['lastEventTime'] != null
          ? DateTime.tryParse(json['lastEventTime'].toString())
          : (steps.isNotEmpty ? steps.last.eventTime : null),
      currentLocation: json['currentLocation']?.toString(),
      currentDisposition: _resolveCurrentDisposition(json, steps),
    );
  }

  static String? _resolveCurrentDisposition(
    Map<String, dynamic> json,
    List<JourneyStep> steps,
  ) {
    final raw = json['currentDisposition']?.toString();
    if (raw != null && raw.isNotEmpty) {
      return CbvDisplayUtils.displayDisposition(raw);
    }
    if (steps.isNotEmpty && steps.last.disposition.isNotEmpty) {
      return CbvDisplayUtils.displayDisposition(steps.last.disposition);
    }
    return null;
  }
}
