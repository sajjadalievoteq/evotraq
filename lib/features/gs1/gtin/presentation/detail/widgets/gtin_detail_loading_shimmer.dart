import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';

/// [OutlineInputBorder] radius; matches M3 text fields.
const double _kOutlineInputRadius = 4;

/// Shimmer layout matching [GTINDetailScreen] form: 9 fields, optional industry
/// [Card]/[ExpansionTile], optional [CustomButtonWidget] when not read-only.
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
              _OutlineFieldBlock(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldWithHelperH),
              const SizedBox(height: _betweenFields),
              _DateFieldRow(color: baseColor, fieldHeight: _fieldH),
              const SizedBox(height: _betweenFields),
              _DateFieldRow(color: baseColor, fieldHeight: _fieldH),
              const SizedBox(height: _sectionGap),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),   const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),
              const SizedBox(height: _betweenFields),
              _OutlineFieldBlock(color: baseColor, height: _fieldH),


              BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                buildWhen: (a, b) => a.settings != b.settings,
                builder: (context, settingsState) {
                  final show = settingsState.settings.isPharmaceuticalMode ||
                      settingsState.settings.isTobaccoMode;
                  if (!show) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Matches [Divider] + gap above extension on [GTINDetailScreen].
                      Container(
                        height: 1,
                        color: baseColor,
                      ),
                      const SizedBox(height: 8),
                      _ExtensionTileSkeleton(color: baseColor),
                    ],
                  );
                },
              ),
              const SizedBox(height: _sectionGap),
              if (!readOnly) _PrimaryButtonBlock(color: baseColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineFieldBlock extends StatelessWidget {
  const _OutlineFieldBlock({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_kOutlineInputRadius),
      ),
    );
  }
}

class _DateFieldRow extends StatelessWidget {
  const _DateFieldRow({
    required this.color,
    required this.fieldHeight,
  });

  final Color color;
  final double fieldHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: fieldHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(_kOutlineInputRadius),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: fieldHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_kOutlineInputRadius),
          ),
        ),
      ],
    );
  }
}

class _ExtensionTileSkeleton extends StatelessWidget {
  const _ExtensionTileSkeleton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _rBox(color, 40, 40, _kOutlineInputRadius),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rBox(color, 180, 16, 4),
                  const SizedBox(height: 6),
                  _rBox(color, 120, 12, 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.expand_more,
              color: color,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButtonBlock extends StatelessWidget {
  const _PrimaryButtonBlock({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Widget _rBox(Color color, double w, double h, double r) {
  return Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
