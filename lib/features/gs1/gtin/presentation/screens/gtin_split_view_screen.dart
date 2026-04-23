import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/screens/gtin_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_loading_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';

class GTINSplitViewScreen extends StatefulWidget {
  const GTINSplitViewScreen({super.key});

  @override
  State<GTINSplitViewScreen> createState() => _GTINSplitViewScreenState();
}

class _GTINSplitViewScreenState extends State<GTINSplitViewScreen> {
  String? _selectedGtinCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GTIN Management')),
      drawer: const AppDrawer(),
      body: BlocListener<GTINCubit, GTINState>(
          listenWhen: (previous, current) => previous.gtins != current.gtins,
          listener: (context, state) {
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
          child: Row(
            spacing: 20,
            children: [
              Flexible(
                flex: 30, // 30%
                child: Padding(
                  padding: const EdgeInsets.only(left: Constants.spacing, right: Constants.spacing,top: Constants.spacing, ),
                  child: GTINListScreen(
                    embedded: true,
                    onSelectGtin: (gtinCode) {
                      if (gtinCode == _selectedGtinCode) return;
                      setState(() => _selectedGtinCode = gtinCode);
                    },
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 70, // 70%
                child: _selectedGtinCode == null
                    ? GtinDetailLoadingShimmer()
                    : Padding(
                  padding: const EdgeInsets.only(left: Constants.spacing, right: Constants.spacing,top: Constants.spacing, ),
                      child: GTINDetailScreen(
                                        key: ValueKey(_selectedGtinCode),
                                        gtinCode: _selectedGtinCode,
                                        isEditing: false,
                                        embedded: true,
                                      ),
                    ),
              ),
            ],
          )
      ),
    );
  }
}

