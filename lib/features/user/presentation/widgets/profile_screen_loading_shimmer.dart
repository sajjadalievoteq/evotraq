import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/responsive_modules_row.dart';
import 'package:traqtrace_app/features/user/presentation/widgets/user_section_card.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileScreenLoadingShimmer extends StatelessWidget {
  const ProfileScreenLoadingShimmer({
    super.key,
    required this.isDesktopWide,
    required this.padding,
  });

  final bool isDesktopWide;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final modules = const [
      UserSectionCard(
        title: UserStrings.infoTitle,
        child: _ProfileInfoSkeleton(),
      ),
      UserSectionCard(
        title: UserStrings.securityTitle,
        child: _ProfileSecuritySkeleton(),
      ),
      UserSectionCard(
        title: UserStrings.preferencesTitle,
        child: _ProfilePreferencesSkeleton(),
      ),
    ];

    return AppShimmer(
      child: Align(
        alignment: isDesktopWide ? Alignment.center : Alignment.topCenter,
        child: SingleChildScrollView(
          padding: padding,
          child: isDesktopWide
              ? ResponsiveModulesRow(children: modules)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    modules[0],
                    const SizedBox(height: 16),
                    modules[1],
                    const SizedBox(height: 16),
                    modules[2],
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProfileInfoSkeleton extends StatelessWidget {
  const _ProfileInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 16),
        _SkeletonCircle(size: 100),
        SizedBox(height: 12),
        _SkeletonBox(width: 220, height: 18),
        SizedBox(height: 8),
        _SkeletonBox(width: 140, height: 14),
        SizedBox(height: 24),
        _SkeletonPill(width: 170, height: 42),
        SizedBox(height: 24),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
      ],
    );
  }
}

class _ProfileSecuritySkeleton extends StatelessWidget {
  const _ProfileSecuritySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SkeletonBox(width: 180, height: 18),
        SizedBox(height: 12),
        _SkeletonBox(width: double.infinity, height: 14),
        SizedBox(height: 6),
        _SkeletonBox(width: double.infinity, height: 14),
        SizedBox(height: 24),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 24),
        _SkeletonPill(width: double.infinity, height: 50),
        SizedBox(height: 32),
        Divider(),
        SizedBox(height: 16),
        _SkeletonBox(width: 120, height: 18),
        SizedBox(height: 12),
        _SkeletonBox(width: 260, height: 14),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 56, radius: 12),
      ],
    );
  }
}

class _ProfilePreferencesSkeleton extends StatelessWidget {
  const _ProfilePreferencesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SkeletonBox(width: 220, height: 18),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 140, radius: 12),
        SizedBox(height: 24),
        _SkeletonBox(width: 220, height: 18),
        SizedBox(height: 16),
        _SkeletonBox(width: double.infinity, height: 220, radius: 12),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  const _SkeletonPill({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: width, height: height, radius: 999);
  }
}
