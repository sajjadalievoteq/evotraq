import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/screens/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';

class GTINSplitViewScreen extends StatefulWidget {
  const GTINSplitViewScreen({super.key});

  @override
  State<GTINSplitViewScreen> createState() => _GTINSplitViewScreenState();
}

class _GTINSplitViewScreenState extends State<GTINSplitViewScreen> {
  String? _selectedGtinCode;
  bool _isAddingGtin = false;

  void _onFabPressed() {
    if (_isAddingGtin) {
      setState(() => _isAddingGtin = false);
      return;
    }
    setState(() => _isAddingGtin = true);
  }

  void _onEmbeddedCreateSuccess() {
    final cubit = context.read<GTINCubit>();
    final newCode = cubit.state.gtin?.gtinCode;
    setState(() {
      _isAddingGtin = false;
      if (newCode != null) {
        _selectedGtinCode = newCode;
      }
    });
    cubit.fetchGTINList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(GtinUiConstants.appBarManagement)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: _isAddingGtin ? 'Close create form' : 'Add New GTIN',
        child: Icon(_isAddingGtin ? Icons.close : Icons.add),
      ),
      body: BlocListener<GTINCubit, GTINState>(
          listenWhen: (previous, current) => previous.gtins != current.gtins,
          listener: (context, state) {
            if (_isAddingGtin) return;
            final gtins = state.gtins;
            if (gtins == null) return;

            if (gtins.isEmpty) {
              if (_selectedGtinCode != null) {
                setState(() => _selectedGtinCode = null);
              }
              return;
            }

            if (_selectedGtinCode == null) {
              setState(() => _selectedGtinCode = gtins.first.gtinCode);
              return;
            }

            // Search/filter may drop the current row; follow the new first match.
            final stillInResults =
                gtins.any((g) => g.gtinCode == _selectedGtinCode);
            if (!stillInResults) {
              setState(() => _selectedGtinCode = gtins.first.gtinCode);
            }
          },
          child: MasterDetailSplitLayout(
            isCreateMode: _isAddingGtin,
            list: GTINListScreen(
              embedded: true,
              onSelectGtin: (gtinCode) {
                if (gtinCode == _selectedGtinCode && !_isAddingGtin) {
                  return;
                }
                setState(() {
                  _isAddingGtin = false;
                  _selectedGtinCode = gtinCode;
                });
              },
            ),
            detail: _buildRightPane(),
          ),
      ),
    );
  }

  Widget _buildRightPane() {
    if (_isAddingGtin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: ColorManager.primary(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Constants.spacing),
              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      GtinUiConstants.splitCreateHeader,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: GtinUiConstants.tooltipClose,
                    color: Colors.white,
                    onPressed: () {
                      setState(() => _isAddingGtin = false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GTINDetailScreen(
              key: const ValueKey('__gtin_embedded_new__'),
              isEditing: true,
              embedded: true,
              onEmbeddedActionSuccess: _onEmbeddedCreateSuccess,
            ),
          ),
        ],
      );
    }

    return BlocBuilder<GTINCubit, GTINState>(
      builder: (context, state) {
        if (state.status == GTINStatus.success &&
            state.gtins != null &&
            state.gtins!.isEmpty &&
            !state.isGtinListLoading) {
          return const Center(
            child: Text(GtinUiConstants.emptyNoMatchSearch),
          );
        }

        final effectiveCode = _selectedGtinCode ??
            (state.gtins != null && state.gtins!.isNotEmpty
                ? state.gtins!.first.gtinCode
                : null);

        if (effectiveCode != null) {
          return GTINDetailScreen(
            key: ValueKey(effectiveCode),
            gtinCode: effectiveCode,
            isEditing: false,
            embedded: true,
          );
        }

        return GTINDetailScreen(
          key: const ValueKey('__gtin_split_await_list__'),
          isEditing: false,
          embedded: true,
          awaitingListSelection: true,
        );
      },
    );
  }
}

