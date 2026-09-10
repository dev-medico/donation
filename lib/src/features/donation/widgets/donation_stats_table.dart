import 'dart:math' as math;

import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

/// One line of a [DonationStatsTable]: a label and how many donations it has.
class StatsRow {
  const StatsRow(this.label, this.count);

  final String label;
  final int count;
}

/// The white report card shared by the blood-group and hospital tables.
///
/// Rows are laid out as three aligned columns (label / count / %) under
/// matching headers, with a total line underneath. The count and % columns
/// are sized to their widest text in the app font, so headers never wrap or
/// drift away from the values beneath them. On phones the card sizes itself
/// to its rows so nothing is ever cut off and the page scrolls as a whole; on
/// wider layouts it keeps the fixed dashboard size and scrolls its rows
/// internally so the side-by-side cards stay level.
class DonationStatsTable extends StatelessWidget {
  const DonationStatsTable({
    super.key,
    required this.title,
    required this.labelHeader,
    required this.rows,
    required this.total,
  });

  final String title;
  final String labelHeader;
  final List<StatsRow> rows;
  final int total;

  /// Share of [total] with one decimal, e.g. `23.2`; `0.0` when there is no
  /// total to divide by.
  static String percentLabel(int count, int total) =>
      total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    // Very narrow phones (320-359 logical px) get a slightly smaller header
    // so the Burmese column titles still share one line.
    final compact = MediaQuery.sizeOf(context).width < 360;
    final headerSize = compact ? 14.0 : (mobile ? 15.5 : 16.5);
    final rowSize = mobile ? 15.0 : 16.0;

    final headerStyle = TextStyle(
      fontSize: headerSize,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    final labelStyle = TextStyle(fontSize: rowSize, color: Colors.black);
    final countStyle = TextStyle(fontSize: rowSize, color: primaryColor);
    final percentStyle =
        TextStyle(fontSize: rowSize, color: Colors.grey.shade600);
    final totalStyle = TextStyle(
      fontSize: mobile ? 15.5 : 16.5,
      color: Colors.grey,
    );
    final totalCountStyle = totalStyle.copyWith(fontWeight: FontWeight.bold);
    final totalPercent = total > 0 ? '100.0' : '0.0';

    final measure = _TextMeasurer(context);
    final columns = _Columns(
      gap: compact ? 6 : 8,
      countWidth: measure.widest([
        ("အရေအတွက်", headerStyle),
        (total.toString(), totalCountStyle),
        for (final row in rows) (row.count.toString(), countStyle),
      ]),
      percentWidth: measure.widest([
        ("%", headerStyle),
        (totalPercent, totalStyle),
        for (final row in rows) (percentLabel(row.count, total), percentStyle),
      ]),
    );

    final rowWidgets = [
      for (final row in rows)
        Padding(
          padding: const EdgeInsets.all(8),
          child: columns.cells(
            label: Text(
              row.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
            count: Text(row.count.toString(), style: countStyle),
            percent: Text(percentLabel(row.count, total), style: percentStyle),
          ),
        ),
    ];

    final body = mobile
        ? Column(mainAxisSize: MainAxisSize.min, children: rowWidgets)
        : Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: rowWidgets,
            ),
          );

    return StatsTableCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: mobile ? 15.5 : 16.5,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: mobile ? 10 : 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: columns.cells(
              label: Text(labelHeader, style: headerStyle),
              count: Text("အရေအတွက်", style: headerStyle),
              percent: Text("%", style: headerStyle),
            ),
          ),
          const SizedBox(height: 4),
          body,
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 1,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: columns.cells(
              label: Text(
                compact ? "စုစုပေါင်း" : "စုစုပေါင်း အရေအတွက်",
                style: totalStyle,
              ),
              count: Text(total.toString(), style: totalCountStyle),
              percent: Text(totalPercent, style: totalStyle),
            ),
          ),
        ],
      ),
    );
  }
}

/// The card chrome around a [DonationStatsTable] — also used on its own for
/// the loading and error states so the page keeps its shape.
class StatsTableCard extends StatelessWidget {
  const StatsTableCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final card = Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(mobile ? 12 : 16),
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
    if (mobile) return card;

    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: size.height * 0.52,
      width: size.width * 0.43,
      child: card,
    );
  }
}

/// Placeholder body for a [StatsTableCard] while data loads or has failed.
class StatsTablePlaceholder extends StatelessWidget {
  const StatsTablePlaceholder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StatsTableCard(
      child: SizedBox(
        height: Responsive.isMobile(context) ? 140 : double.infinity,
        child: Center(child: child),
      ),
    );
  }
}

/// Measures text the way it will actually paint: in the ambient text style
/// (which carries the app's Burmese font) and at the user's text scale.
class _TextMeasurer {
  _TextMeasurer(BuildContext context)
      : _base = DefaultTextStyle.of(context).style,
        _scaler = MediaQuery.textScalerOf(context);

  final TextStyle _base;
  final TextScaler _scaler;

  double width(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _base.merge(style)),
      textDirection: TextDirection.ltr,
      textScaler: _scaler,
    )..layout();
    final result = painter.width;
    painter.dispose();
    return result;
  }

  /// Width of the widest sample, plus a hair of slack so glyph side bearings
  /// never push a value onto a second line.
  double widest(List<(String, TextStyle)> samples) {
    var result = 0.0;
    for (final (text, style) in samples) {
      result = math.max(result, width(text, style));
    }
    return result.ceilToDouble() + 2;
  }
}

class _Columns {
  const _Columns({
    required this.countWidth,
    required this.percentWidth,
    required this.gap,
  });

  final double countWidth;
  final double percentWidth;
  final double gap;

  /// A row whose count and percent cells sit in fixed-width, right-aligned
  /// columns so headers, values and the total line up.
  Widget cells({
    required Widget label,
    required Widget count,
    required Widget percent,
  }) {
    return Row(
      children: [
        Expanded(child: label),
        SizedBox(width: gap),
        SizedBox(
          width: countWidth,
          child: Align(alignment: Alignment.centerRight, child: count),
        ),
        SizedBox(width: gap),
        SizedBox(
          width: percentWidth,
          child: Align(alignment: Alignment.centerRight, child: percent),
        ),
      ],
    );
  }
}
