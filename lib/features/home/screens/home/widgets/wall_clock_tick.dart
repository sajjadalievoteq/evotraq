import 'package:flutter/material.dart';

class WallClockTick extends StatefulWidget {
  const WallClockTick({super.key, required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<WallClockTick> createState() => _WallClockTickState();
}

class _WallClockTickState extends State<WallClockTick> {
  late final Stream<DateTime> _everySecond;

  @override
  void initState() {
    super.initState();
    _everySecond = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _everySecond,
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        return widget.builder(context, now);
      },
    );
  }
}
