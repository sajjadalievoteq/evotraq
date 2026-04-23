import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/screens/gtin_split_view_screen.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Main screen for GTIN (Global Trade Item Number) functionality
class GTINScreen extends StatefulWidget {
  const GTINScreen({Key? key}) : super(key: key);

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
      child: AppLayoutBuilder(
        builder: (context, layout) {
          final showSplit = layout.isDesktopUp;

          // Keep both trees mounted so resizing doesn't recreate screens/cubit.
          return IndexedStack(
            index: showSplit ? 0 : 1,
            children: const [
              GTINSplitViewScreen(),
              GTINListScreen(),
            ],
          );
        },
      ),
    );
  }
}
