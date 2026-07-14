// Tobacco industry extension UI (GTIN/GLN/SSCC detail).
// Enable at build/run time:
//   flutter run --dart-define=TOBACCO_EXTENSION_ENABLED=true
const bool kTobaccoExtensionEnabled = bool.fromEnvironment(
  'TOBACCO_EXTENSION_ENABLED',
  defaultValue: false,
);
