import 'dart:async';

const Duration kGs1MasterListSearchDebounce = Duration(milliseconds: 400);

class Gs1ListSearchDebouncer {
  Gs1ListSearchDebouncer({
    this.duration = kGs1MasterListSearchDebounce,
    required this.onDebounced,
  });

  final Duration duration;
  final void Function() onDebounced;
  Timer? _timer;

  void cancel() => _timer?.cancel();

  void schedule() {
    cancel();
    _timer = Timer(duration, onDebounced);
  }

  void dispose() {
    cancel();
  }
}
