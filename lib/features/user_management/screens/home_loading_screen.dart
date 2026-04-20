import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  Widget _box({
    double width = double.infinity,
    double height = 80,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _sectionTitle({double width = 180}) {
    return _box(width: width, height: 20, radius: 8);
  }

  Widget _statsGrid(double maxWidth) {
    double cardWidth;
    if (maxWidth < 400) {
      cardWidth = (maxWidth - 12) / 2;
    } else if (maxWidth < 600) {
      cardWidth = (maxWidth - 24) / 3;
    } else if (maxWidth < 900) {
      cardWidth = (maxWidth - 36) / 4;
    } else {
      cardWidth = (maxWidth - 48) / 5;
    }
    cardWidth = cardWidth.clamp(100.0, 160.0);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(9, (_) => _box(width: cardWidth, height: 96)),
    );
  }

  Widget _quickActions(double maxWidth) {
    int crossAxisCount;
    if (maxWidth < 600) {
      crossAxisCount = 3;
    } else if (maxWidth < 900) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 6;
    }

    final spacing = 16.0;
    final itemWidth =
        (maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(maxWidth<900?6:8, (_) => _box(width: itemWidth, height: itemWidth-50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 600 ? 12.0 : 16.0;
              final verticalSpacing = constraints.maxWidth < 600 ? 16.0 : 24.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 100, radius: 16),
                    SizedBox(height: verticalSpacing),
                    _sectionTitle(width: 170),
                    const SizedBox(height: 12),
                    _statsGrid(constraints.maxWidth - (horizontalPadding * 2)),
                    SizedBox(height: verticalSpacing),
                    _sectionTitle(width: 140),
                    const SizedBox(height: 12),
                    _quickActions(constraints.maxWidth - (horizontalPadding * 2)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
