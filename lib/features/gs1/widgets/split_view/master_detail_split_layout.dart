import 'package:flutter/material.dart';

/// Two-pane master–detail row: list (left), divider, detail (right).
/// Padding and flex follow the GS1 split-view spec used by GTIN and GLN.
class MasterDetailSplitLayout extends StatelessWidget {
  const MasterDetailSplitLayout({
    super.key,
    required this.list,
    required this.detail,
    this.narrowListFlex = 40,
    this.wideListFlex = 30,
    this.narrowWidthBreakpoint = 1100,
  });

  final Widget list;
  final Widget detail;

  /// [list] flex when the row is narrower than [narrowWidthBreakpoint].
  final int narrowListFlex;

  /// [list] flex at wider widths; detail uses the remainder to 100.
  final int wideListFlex;

  final double narrowWidthBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.sizeOf(context);
        final rawW = constraints.maxWidth;
        final width = (rawW.isFinite && rawW >= 1.0) ? rawW : media.width;
        final listFlex =
            width < narrowWidthBreakpoint ? narrowListFlex : wideListFlex;
        final detailFlex = 100 - listFlex;

        return Row(
          children: [
            Flexible(
              flex: listFlex,
              child: list,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: detailFlex,
              child: detail,
            ),
          ],
        );
      },
    );
  }
}
