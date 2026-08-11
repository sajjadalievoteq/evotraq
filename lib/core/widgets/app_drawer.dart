import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_view.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/utils/drawer_scroll_memory.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final ScrollController _scrollController;

  bool _hasOpenedOnce = false;

  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: DrawerScrollMemory.consumeOffset(),
    );
    DrawerScrollMemory.openNotifier.addListener(_onDrawerOpened);
  }

  @override
  void dispose() {
    DrawerScrollMemory.openNotifier.removeListener(_onDrawerOpened);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDrawerOpened() {
    if (!_hasOpenedOnce) {
      _hasOpenedOnce = true;
      return;
    }
    if (!_didNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _didNavigate = false;
  }

  void _navigate(String route, {bool isDashboard = false, Object? extra}) {
    final offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    _didNavigate = true;
    if (isDashboard) {
      DrawerScrollMemory.clearRestore();
    } else {
      DrawerScrollMemory.saveForRestore(offset);
    }
    context.go(route, extra: extra);
  }

  bool _canOp(AuthState auth, String step) => auth.canPerform(step);

  bool _hasAnyOperationNav(AuthState auth) =>
      _canOp(auth, OperationSteps.commission) ||
      _canOp(auth, OperationSteps.updateStatus) ||
      _canOp(auth, OperationSteps.pack) ||
      _canOp(auth, OperationSteps.unpack) ||
      _canOp(auth, OperationSteps.ship) ||
      _canOp(auth, OperationSteps.cancelShip) ||
      _canOp(auth, OperationSteps.returnShip) ||
      _canOp(auth, OperationSteps.receive) ||
      _canOp(auth, OperationSteps.cancelReceive) ||
      _canOp(auth, OperationSteps.returnReceive);

  @override
  Widget build(BuildContext context) {
    return AppDrawerView(
      scrollController: _scrollController,
      onNavigate: _navigate,
    );
  }
}
