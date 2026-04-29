import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/screens/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_loading_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

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
      appBar: AppBar(title: const Text('GTIN Management')),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final listFlex = width < 1100 ? 40 : 30;
              final detailFlex = 100 - listFlex;
              return AppLayoutBuilder(
                builder: (context, layout) {
                  final edge = (layout.horizontalPadding * 0.5 + Constants.spacing * 0.5)
                      .clamp(12.0, 24.0);
                  return Row(
                    // spacing: width < 900 ? 12 : 20,
                    children: [
                      Flexible(
                        flex: listFlex,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            edge,
                            edge,
                            edge,
                            0
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left:width < 900 ? 12 : 20, right: width < 900 ? 12 : 20, top: width < 900 ? 12 : 20),
                            child: GTINListScreen(
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
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: detailFlex,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            edge,
                            0,
                            edge,
                          0
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left:width < 900 ? 12 : 20, right: width < 900 ? 12 : 20, top: width < 900 ? _isAddingGtin? 12:2 : _isAddingGtin?20:10),
                            child: _buildRightPane(width),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
      ),
    );
  }

  Widget _buildRightPane(double width) {
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
                      'Create GTIN',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
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

    if (_selectedGtinCode == null) {
      return const GtinDetailLoadingShimmer();
    }

    return GTINDetailScreen(
      key: ValueKey(_selectedGtinCode),
      gtinCode: _selectedGtinCode,
      isEditing: false,
      embedded: true,
    );
  }
}

