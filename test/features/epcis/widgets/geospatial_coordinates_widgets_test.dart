import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial/geospatial_coordinates_info.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial/geospatial_coordinates_dialog.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial_coordinates_widget.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('coordinate info preserves location and accuracy formatting', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GeospatialCoordinatesInfo(
          coordinates: GeospatialCoordinates(
            latitude: 25.204849,
            longitude: 55.270783,
            altitude: 12.5,
            horizontalAccuracy: 3,
            verticalAccuracy: 5,
            name: 'Dubai Warehouse',
          ),
        ),
      ),
    );

    expect(find.text('Dubai Warehouse'), findsOneWidget);
    expect(find.text('25.204849°, 55.270783°'), findsOneWidget);
    expect(find.textContaining('±3.0m horiz.'), findsOneWidget);
    expect(find.textContaining('±5.0m vert.'), findsOneWidget);
  });

  testWidgets('view-only container preserves no-coordinate state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GeospatialCoordinatesWidget(isViewOnly: true, showMap: false),
      ),
    );

    expect(find.text('No geospatial coordinates available'), findsOneWidget);
  });

  testWidgets('coordinates dialog preserves required-range validation', (
    tester,
  ) async {
    await tester.pumpWidget(_host(GeospatialCoordinatesDialog(onSave: (_) {})));
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Please enter latitude'), findsOneWidget);
    expect(find.text('Please enter longitude'), findsOneWidget);
  });

  testWidgets('coordinates dialog preserves edit values and save callback', (
    tester,
  ) async {
    GeospatialCoordinates? saved;
    await tester.pumpWidget(
      _host(
        GeospatialCoordinatesDialog(
          coordinates: const GeospatialCoordinates(
            latitude: 25.2,
            longitude: 55.27,
            name: 'Warehouse',
          ),
          onSave: (coordinates) => saved = coordinates,
        ),
      ),
    );

    expect(find.text('Edit Coordinates'), findsOneWidget);
    expect(find.text('25.2'), findsOneWidget);
    expect(find.text('55.27'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved?.latitude, 25.2);
    expect(saved?.longitude, 55.27);
    expect(saved?.name, 'Warehouse');
  });
}
