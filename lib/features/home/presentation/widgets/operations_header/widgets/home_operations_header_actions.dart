import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_elevated_icon_button.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_navigation.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

class HomeOperationsHeaderActions extends StatelessWidget {
  const HomeOperationsHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TraqElevatedIconButton(
          onPressed: () => context.go(HomeNavigation.epcisObjectEventNew),
          icon: SvgPicture.asset(
            AppAssets.iconPlus,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(scheme.onPrimary, BlendMode.srcIn),
          ),
          label: HomeStrings.newEventButton,
        ),
      ],
    );
  }
}
