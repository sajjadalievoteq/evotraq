import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/screens/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

/// Main screen for GTIN (Global Trade Item Number) functionality
class GTINScreen extends StatefulWidget {
  const GTINScreen({super.key});

  @override
  State<GTINScreen> createState() => _GTINScreenState();
}

class _GTINScreenState extends State<GTINScreen> {
  late final GTINCubit _gtinCubit;

  @override
  void initState() {
    super.initState();
    _gtinCubit = getIt<GTINCubit>();
  }

  @override
  void dispose() {
    _gtinCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gtinCubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<GTINCubit, GTINState>(
          appBarTitle: GtinUiConstants.appBarManagement,
          fabHeroTag: 'gtin_split_view_add_fab',
          fabAddTooltip: 'Add New GTIN',
          fabCloseTooltip: 'Close create form',
          createHeaderText: GtinUiConstants.splitCreateHeader,
          closeCreateTooltip: GtinUiConstants.tooltipClose,
          emptyNoMatchText: GtinUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.gtins != current.gtins,
          idsFromState: (s) => s.gtins?.map((g) => g.gtinCode),
          createdIdFromState: (s) => s.gtin?.gtinCode,
          isEmptyNoMatch: (s) =>
              s.status == GTINStatus.success &&
              s.gtins != null &&
              s.gtins!.isEmpty &&
              !s.isGtinListLoading,
          listBuilder: (context,
                  {required onSelect,
                  required bindRefresh,
                  required onRequestCreate}) =>
              GTINListScreen(
            embedded: true,
            onSelectGtin: onSelect,
          ),
          detailViewBuilder: (context, code) => GTINDetailScreen(
            key: ValueKey(code),
            gtinCode: code,
            isEditing: false,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) => GTINDetailScreen(
            key: const ValueKey('__gtin_embedded_new__'),
            isEditing: true,
            embedded: true,
            onEmbeddedActionSuccess: () {
              onSuccess();
              context.read<GTINCubit>().fetchGTINList();
            },
          ),
          detailAwaitBuilder: (context) => const GTINDetailScreen(
            key: ValueKey('__gtin_split_await_list__'),
            isEditing: false,
            embedded: true,
            awaitingListSelection: true,
          ),
        ),
        fallback: const GTINListScreen(),
      ),
    );
  }
}
