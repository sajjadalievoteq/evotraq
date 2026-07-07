/// Allowed reason values when status = Sample (non_sellable_other).
abstract final class SampleReasonOptions {
  static const List<String> values = [
    'Consumer Report',
    'Criminal Investigation',
    'Laboratory Sample',
    'Packaging Review',
    'Prequalification',
    'Product Documentation',
    'Retention for future testing',
    'Sample for Doctors',
    'Sampling through PMS (Posta Marketing Surveillance)',
    'Storing condition',
    'Suspect activity',
  ];
}

/// Allowed reason values when status = Damaged (damaged).
abstract final class DamagedReasonOptions {
  static const List<String> values = [
    '2D Matrix not readable',
    'Broken',
    'Damage due to liquid spill',
    'Other',
    'Smashed',
    'Torn',
    'Unfolded',
  ];
}
