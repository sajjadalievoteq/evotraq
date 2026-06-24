const objectEventFormSourceDestinationTypes = [
  ('owning_party', 'Owning Party'),
  ('possessing_party', 'Possessing Party'),
  ('location', 'Location'),
];

String objectEventFormSourceDestinationLabel(String type) {
  for (final entry in objectEventFormSourceDestinationTypes) {
    if (entry.$1 == type) return entry.$2;
  }
  return type;
}
