import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/screens/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/screens/sscc_list_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class SSCCScreen extends StatefulWidget {
  const SSCCScreen({super.key});

  @override
  State<SSCCScreen> createState() => _SSCCScreenState();
}

class _SSCCScreenState extends State<SSCCScreen> {
  late final SSCCCubit _ssccCubit;

  @override
  void initState() {
    super.initState();
    _ssccCubit = SSCCCubit(ssccService: getIt<SSCCService>());
  }

  @override
  void dispose() {
    _ssccCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ssccCubit,
      child: SplitOrListIndexedStack(
        split: Gs1SplitViewScreen<SSCCCubit, SSCCState>(
          appBarTitle: SsccUiConstants.appBarManagement,
          fabHeroTag: 'sscc_split_view_add_fab',
          fabAddTooltip: SsccUiConstants.fabAddNew,
          fabCloseTooltip: SsccUiConstants.fabCloseCreate,
          createHeaderText: SsccUiConstants.splitCreateHeader,
          closeCreateTooltip: SsccUiConstants.tooltipClose,
          emptyNoMatchText: SsccUiConstants.emptyNoMatchSearch,
          listenWhenListChanged: (previous, current) =>
              previous.ssccs != current.ssccs,
          idsFromState: (s) => s.ssccs
              .map((item) => item.ssccCode)
              .where((code) => RegExp(r'^\d{18}$').hasMatch(code)),
          createdIdFromState: (s) => s.selectedSSCC?.ssccCode,
          isEmptyNoMatch: (s) =>
              s.status == SSCCStatus.success && s.ssccs.isEmpty,
          listBuilder: (
            context, {
            required selectedId,
            required onSelect,
            required bindRefresh,
            required onRequestCreate,
          }) =>
              SSCCListScreen(
            embedded: true,
            selectedSsccCode: selectedId,
            onBindRefresh: bindRefresh,
            onEmbeddedCreate: onRequestCreate,
            onSelectSscc: onSelect,
          ),
          detailViewBuilder: (context, code) => SSCCDetailScreen(
            key: ValueKey(code),
            ssccCode: code,
            isEditing: false,
            embedded: true,
          ),
          detailCreateBuilder: (context, onSuccess) => SSCCDetailScreen(
            key: const ValueKey('__sscc_embedded_new__'),
            isEditing: true,
            embedded: true,
            onEmbeddedActionSuccess: () {
              onSuccess();
              context.read<SSCCCubit>().loadSSCCList();
            },
          ),
          detailAwaitBuilder: (context) => const SSCCDetailScreen(
            key: ValueKey('__sscc_split_await_list__'),
            isEditing: false,
            embedded: true,
            awaitingListSelection: true,
          ),
        ),
        fallback: const SSCCListScreen(),
      ),
    );
  }
}
