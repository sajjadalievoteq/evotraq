import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/sgtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_list/sgtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class SGTINScreen extends StatefulWidget {
  const SGTINScreen({super.key});

  @override
  State<SGTINScreen> createState() => _SGTINScreenState();
}

class _SGTINScreenState extends State<SGTINScreen> {
  late final SGTINCubit _sgtinCubit;

  @override
  void initState() {
    super.initState();
    _sgtinCubit = getIt<SGTINCubit>();
  }

  @override
  void dispose() {
    _sgtinCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _sgtinCubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<SGTINCubit, SGTINState>(
          appBarTitle: SgtinUiConstants.appBarManagement,
          fabHeroTag: 'sgtin_split_view_add_fab',
          fabAddTooltip: SgtinUiConstants.fabAddNew,
          fabCloseTooltip: SgtinUiConstants.fabCloseCreate,
          createHeaderText: SgtinUiConstants.splitCreateHeader,
          closeCreateTooltip: SgtinUiConstants.tooltipClose,
          emptyNoMatchText: SgtinUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.sgtins != current.sgtins,
          idsFromState: (s) => s.sgtins?.map((g) => g.id ?? g.serialNumber),
          createdIdFromState: (s) => s.sgtin?.id,
          isEmptyNoMatch: (s) =>
              s.status == SGTINStatus.success &&
              s.sgtins != null &&
              s.sgtins!.isEmpty,
          listBuilder:
              (
                context, {
                required selectedId,
                required onSelect,
                required bindRefresh,
                required onRequestCreate,
              }) => SGTINListScreen(
                embedded: true,
                selectedSgtinId: selectedId,
                onSelectSgtin: onSelect,
                onEmbeddedCreate: onRequestCreate,
              ),
          detailViewBuilder: (context, id) => SGTINDetailScreen(
            key: ValueKey(id),
            sgtinId: id,
            isEditing: false,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) => SGTINDetailScreen(
            key: const ValueKey('__sgtin_embedded_new__'),
            isEditing: true,
            embedded: true,
            onEmbeddedActionSuccess: () {
              onSuccess();
              _sgtinCubit.fetchSGTINList();
            },
          ),
          detailAwaitBuilder: (context, {required listLoading}) =>
              const SGTINDetailScreen(
                key: ValueKey('__sgtin_split_await_list__'),
                isEditing: false,
                embedded: true,
                awaitingListSelection: true,
              ),
        ),
        fallback: const SGTINListScreen(),
      ),
    );
  }
}
