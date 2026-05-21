import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/screens/sgtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/list/screens/sgtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class SGTINScreen extends StatelessWidget {
  const SGTINScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The SGTINCubit is provided globally in main.dart.
    // Re-expose it via BlocProvider.value so child widgets can access it
    // without the split-view creating a second instance.
    return BlocProvider.value(
      value: context.read<SGTINCubit>(),
      child: Builder(
        builder: (ctx) => SplitOrListIndexedStack(
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
            idsFromState: (s) =>
                s.sgtins?.map((g) => g.id ?? g.serialNumber),
            createdIdFromState: (s) => s.sgtin?.id,
            isEmptyNoMatch: (s) =>
                s.status == SGTINStatus.success &&
                s.sgtins != null &&
                s.sgtins!.isEmpty,
            listBuilder: (
              context, {
              required onSelect,
              required bindRefresh,
              required onRequestCreate,
            }) =>
                SGTINListScreen(
              embedded: true,
              onSelectSgtin: onSelect,
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
                ctx.read<SGTINCubit>().fetchSGTINList();
              },
            ),
            detailAwaitBuilder: (context) => const SGTINDetailScreen(
              key: ValueKey('__sgtin_split_await_list__'),
              isEditing: false,
              embedded: true,
              awaitingListSelection: true,
            ),
          ),
          fallback: const SGTINListScreen(),
        ),
      ),
    );
  }
}
