import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit_session.dart';

/// Tracks input so web sessions can idle-logout. No-op on mobile.
class SessionActivityListener extends StatefulWidget {
  const SessionActivityListener({super.key, required this.child});

  final Widget child;

  @override
  State<SessionActivityListener> createState() => _SessionActivityListenerState();
}

class _SessionActivityListenerState extends State<SessionActivityListener> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      HardwareKeyboard.instance.addHandler(_onKeyEvent);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    }
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _markActivity();
    }
    return false;
  }

  void _markActivity() {
    if (!mounted) return;
    context.read<AuthCubit>().noteUserActivity();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _markActivity(),
      onPointerSignal: (_) => _markActivity(),
      child: widget.child,
    );
  }
}
