import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class EpcisGenericEventDetailScreen extends StatelessWidget {
  const EpcisGenericEventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.epcisGenericEventDetailTitle),
      ),
      body: Center(
        child: Text(
          '${Constants.epcisGenericEventDetailViewingPrefix} $eventId',
        ),
      ),
    );
  }
}
