import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Two-pane master–detail row: list (left), divider, detail (right).
/// Padding and flex follow the GS1 split-view spec used by GTIN and GLN.
class MasterDetailSplitLayout extends StatelessWidget {
  const MasterDetailSplitLayout({
    super.key,
    required this.list,
    required this.detail,
    this.isCreateMode = false,
    this.narrowListFlex = 40,
    this.wideListFlex = 30,
    this.narrowWidthBreakpoint = 1100,
  });

  final Widget list;
  final Widget detail;
  final bool isCreateMode;

  /// [list] flex when the row is narrower than [narrowWidthBreakpoint].
  final int narrowListFlex;

  /// [list] flex at wider widths; detail uses the remainder to 100.
  final int wideListFlex;

  final double narrowWidthBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final listFlex = width < narrowWidthBreakpoint ? narrowListFlex : wideListFlex;
        final detailFlex = 100 - listFlex;
        return AppLayoutBuilder(
          builder: (context, layout) {
            final edge = (layout.horizontalPadding * 0.5 + Constants.spacing * 0.5)
                .clamp(12.0, 24.0);
            final gutter = width < 900 ? 12.0 : 20.0;
            final detailTop = width < 900
                ? (isCreateMode ? 12.0 : 2.0)
                : (isCreateMode ? 20.0 : 10.0);

            return Row(
              children: [
                Flexible(
                  flex: listFlex,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(edge, edge, edge, 0),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: gutter,
                        right: gutter,
                        top: gutter,
                      ),
                      child: list,
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: detailFlex,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(edge, 0, edge, 0),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: gutter,
                        right: gutter,
                        top: detailTop,
                      ),
                      child: detail,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
