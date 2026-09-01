import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';

typedef MasterDetailSelectCallback = void Function(String id, {bool editing});

class MasterDetailRouteSelection {
  const MasterDetailRouteSelection({
    required this.selectedId,
    this.editing = false,
  });

  final String selectedId;
  final bool editing;
}

abstract final class MasterDetailRoute {
  static const selectedParam = 'selected';
  static const modeParam = 'mode';
  static const editMode = 'edit';

  static MasterDetailRouteSelection? selectionFrom(GoRouterState state) {
    final selected = state.uri.queryParameters[selectedParam]?.trim();
    if (selected == null || selected.isEmpty) return null;
    return MasterDetailRouteSelection(
      selectedId: selected,
      editing: state.uri.queryParameters[modeParam] == editMode,
    );
  }

  static String? redirectToListIfDesktop(
    BuildContext context, {
    required String listRoute,
    required String selectedId,
    bool editing = false,
  }) {
    if (!context.layout.isDesktopUp) return null;
    return _listUri(
      listRoute: listRoute,
      selectedId: selectedId,
      editing: editing,
    ).toString();
  }

  static String? redirectDetailRouteIfDesktop(
    BuildContext context, {
    required String? authRedirect,
    required String listRoute,
    required String selectedId,
    bool editing = false,
  }) {
    if (authRedirect != null) return authRedirect;
    if (selectedId.isEmpty) return null;
    return redirectToListIfDesktop(
      context,
      listRoute: listRoute,
      selectedId: selectedId,
      editing: editing,
    );
  }

  static void applyListSelection(
    BuildContext context, {
    required String listRoute,
    required String selectedId,
    bool editing = false,
  }) {
    if (!context.layout.isDesktopUp) return;
    final uri = _listUri(
      listRoute: listRoute,
      selectedId: selectedId,
      editing: editing,
    );
    final current = GoRouterState.of(context).uri;
    if (current.path == uri.path &&
        current.queryParameters[selectedParam] == selectedId &&
        (editing
            ? current.queryParameters[modeParam] == editMode
            : current.queryParameters[modeParam] != editMode)) {
      return;
    }
    context.go(uri.toString());
  }

  static Uri _listUri({
    required String listRoute,
    required String selectedId,
    required bool editing,
  }) {
    final params = <String, String>{selectedParam: selectedId};
    if (editing) params[modeParam] = editMode;
    return Uri(path: listRoute, queryParameters: params);
  }
}

abstract final class MasterDetailNavigation {
  static void openItem(
    BuildContext context, {
    required String id,
    void Function(String id, {bool editing})? onSelect,
    required String listRoute,
    required String Function(String id) fullPageRoute,
    bool editing = false,
  }) {
    if (onSelect != null) {
      onSelect(id, editing: editing);
      MasterDetailRoute.applyListSelection(
        context,
        listRoute: listRoute,
        selectedId: id,
        editing: editing,
      );
      return;
    }
    context.push(fullPageRoute(id));
  }
}

class MasterDetailMobileRedirect extends StatefulWidget {
  const MasterDetailMobileRedirect({
    super.key,
    required this.listRoute,
    required this.child,
    this.detailRoute,
    this.editRoute,
  });

  final String listRoute;
  final Widget child;
  final String Function(String selectedId)? detailRoute;
  final String Function(String selectedId)? editRoute;

  @override
  State<MasterDetailMobileRedirect> createState() =>
      _MasterDetailMobileRedirectState();
}

class _MasterDetailMobileRedirectState extends State<MasterDetailMobileRedirect> {
  String? _handledKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.layout.isDesktopUp) return;

    final selection = MasterDetailRoute.selectionFrom(GoRouterState.of(context));
    if (selection == null) return;

    final key = '${selection.selectedId}:${selection.editing}';
    if (_handledKey == key) return;
    _handledKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = selection.editing
          ? widget.editRoute?.call(selection.selectedId)
          : widget.detailRoute?.call(selection.selectedId);
      if (route != null) context.push(route);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}