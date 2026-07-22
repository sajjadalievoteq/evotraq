


abstract final class JourneyAnimationConstants {
  
  static const int canvasPaneSwitchMs = 800;

  
  
  
  static const int canvasEntranceMs = 1200;
  static const double lineProgressStart = 0.0;
  static const double lineProgressEnd = 0.60;
  static const double pinStaggerStartOffset = 0.28;
  static const double durationChipStaggerStartOffset = 0.38;
  static const double pinStaggerWindow = 0.45;
  static const double pinStaggerMaxStart = 0.95;

  
  static const int pinFilterDimMs = 260;
  static const int pinFilterBounceMs = 920;

  
  static const int pinSelectedPulseMs = 1400;
  static const int pinSelectedScaleMs = 220;

  
  static const int filterChipBounceMs = 280;

  
  static const int stepMarkerScaleMs = 200;

  static Duration get canvasPaneSwitch =>
      const Duration(milliseconds: canvasPaneSwitchMs);

  static Duration get canvasEntrance =>
      const Duration(milliseconds: canvasEntranceMs);

  static Duration get pinFilterDim =>
      const Duration(milliseconds: pinFilterDimMs);

  static Duration get pinFilterBounce =>
      const Duration(milliseconds: pinFilterBounceMs);

  static Duration get pinSelectedPulse =>
      const Duration(milliseconds: pinSelectedPulseMs);

  static Duration get pinSelectedScale =>
      const Duration(milliseconds: pinSelectedScaleMs);

  static Duration get filterChipBounce =>
      const Duration(milliseconds: filterChipBounceMs);

  static Duration get stepMarkerScale =>
      const Duration(milliseconds: stepMarkerScaleMs);
}
