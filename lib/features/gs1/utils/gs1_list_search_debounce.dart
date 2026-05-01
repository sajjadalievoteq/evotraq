import 'dart:async';

/// Default delay for master-data list search-as-you-type (GTIN/GLN lists).
const Duration kGs1MasterListSearchDebounce = Duration(milliseconds: 400);

/// Cancels pending timer on [schedule]; use [cancel] (or [dispose]) before
/// immediate search (refresh, submit, clear filters).
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
