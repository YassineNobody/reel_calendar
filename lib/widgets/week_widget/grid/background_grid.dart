import 'package:flutter/widgets.dart';

class TimeGridBackground extends StatelessWidget {
  final DateTime startOfWeek; // 👈 AJOUT
  final int dayCount;
  final double dayWidth;
  final double hourHeight;
  final bool showLeftBorder;

  const TimeGridBackground({
    super.key,
    required this.startOfWeek,
    required this.dayCount,
    required this.dayWidth,
    required this.hourHeight,
    required this.showLeftBorder,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(dayCount * dayWidth, 24 * hourHeight),
      painter: _TimeGridPainter(
        startOfWeek: startOfWeek,
        dayCount: dayCount,
        dayWidth: dayWidth,
        hourHeight: hourHeight,
        showLeftBorder: showLeftBorder,
      ),
    );
  }
}

class _TimeGridPainter extends CustomPainter {
  final DateTime startOfWeek; // 👈 AJOUT
  final int dayCount;
  final double dayWidth;
  final double hourHeight;
  final bool showLeftBorder;

  const _TimeGridPainter({
    required this.startOfWeek,
    required this.dayCount,
    required this.dayWidth,
    required this.hourHeight,
    required this.showLeftBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hourPaint = Paint()
      ..color = Color.fromARGB(255, 223, 223, 223)
      ..strokeWidth = 1;

    final daySeparatorPaint = Paint()
      ..color = Color.fromARGB(255, 223, 223, 223)
      ..strokeWidth = 1;

    // ─────────────────────────────────────
    // 🟫 FOND WEEK-END (AVANT LES LIGNES)
    // ─────────────────────────────────────
    for (int d = 0; d < dayCount; d++) {
      final dayDate = startOfWeek.add(Duration(days: d));
      final isWeekend =
          dayDate.weekday == DateTime.saturday ||
          dayDate.weekday == DateTime.sunday;

      if (isWeekend) {
        canvas.drawRect(
          Rect.fromLTWH(d * dayWidth, 0, dayWidth, size.height),
          Paint()
            ..color = const Color.fromARGB(
              137,
              238,
              238,
              238,
            ), // gris très léger
        );
      }
    }

    /// ─── LIGNES HORIZONTALES
    for (int h = 1; h < 24; h++) {
      final y = h * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hourPaint);
    }

    /// ─── BORDURE GAUCHE (swipe)
    if (showLeftBorder) {
      canvas.drawLine(
        const Offset(0, 0),
        Offset(0, size.height),
        daySeparatorPaint,
      );
    }

    /// ─── SÉPARATEURS DE JOURS
    for (int d = 1; d < dayCount; d++) {
      final x = d * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), daySeparatorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimeGridPainter old) {
    return old.startOfWeek != startOfWeek ||
        old.dayCount != dayCount ||
        old.dayWidth != dayWidth ||
        old.hourHeight != hourHeight ||
        old.showLeftBorder != showLeftBorder;
  }
}
