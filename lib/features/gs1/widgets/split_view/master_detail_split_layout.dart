import 'package:flutter/material.dart';

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

  final int narrowListFlex;

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
              fit: FlexFit.tight,
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
