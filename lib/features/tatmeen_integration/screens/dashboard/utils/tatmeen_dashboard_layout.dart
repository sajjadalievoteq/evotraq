double tatmeenKpiCardWidth(double availableWidth, double gap) {
  final columns = switch (availableWidth) {
    >= 1200 => 4,
    >= 760 => 2,
    _ => 1,
  };
  return (availableWidth - (gap * (columns - 1))) / columns;
}
