import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

/// Full-page placeholder (e.g. routes that do not yet mount the real form). Prefer
/// [GtinFieldSkeletonMask] on each section for in-place loading.
class GtinDetailLoadingShimmer extends StatelessWidget {
  const GtinDetailLoadingShimmer({
    super.key,
    this.readOnly = true,
  });

  final bool readOnly;

  static const _betweenFields = 16.0;
  static const _sectionGap = 32.0;
  static const _fieldH = 56.0;
  static const _fieldWithHelperH = 76.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Constants.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GtinSkeletonOutlineField(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonDateRow(color: baseColor, fieldHeight: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonDateRow(color: baseColor, fieldHeight: _fieldH),
              const SizedBox(height: _sectionGap),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              GtinSkeletonOutlineField(color: baseColor, height: _fieldH),
              BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                buildWhen: (a, b) => a.settings != b.settings,
                builder: (context, settingsState) {
                  final show = settingsState.settings.isPharmaceuticalMode ||
                      (settingsState.settings.isTobaccoMode &&
                          kTobaccoExtensionEnabled);
                  if (!show) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 1, color: baseColor),
                      const SizedBox(height: 8),
                      GtinSkeletonExtensionTile(color: baseColor),
                    ],
                  );
                },
              ),
              const SizedBox(height: _sectionGap),
              if (!readOnly) GtinSkeletonPrimaryButton(color: baseColor),
            ],
          ),
        ),
      ),
    );
  }
}
