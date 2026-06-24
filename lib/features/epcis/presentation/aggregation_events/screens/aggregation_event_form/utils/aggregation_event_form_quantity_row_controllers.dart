import 'package:flutter/material.dart';

class AggregationEventFormQuantityRowControllers {
  AggregationEventFormQuantityRowControllers()
      : epcClass = TextEditingController(),
        quantity = TextEditingController(),
        uom = TextEditingController();

  final TextEditingController epcClass;
  final TextEditingController quantity;
  final TextEditingController uom;

  void dispose() {
    epcClass.dispose();
    quantity.dispose();
    uom.dispose();
  }
}
