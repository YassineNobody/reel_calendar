import 'dart:async';
import 'package:flutter/widgets.dart';

class NowIndicator extends StatefulWidget {
  final double hourHeight;
  final double dayWidth;
  final DateTime startOfWeek;

  const NowIndicator({
    super.key,
    required this.hourHeight,
    required this.dayWidth,
    required this.startOfWeek,
  });

  @override
  State<NowIndicator> createState() => _NowIndicatorState();
}

class _NowIndicatorState extends State<NowIndicator> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final todayIndex = List.generate(7, (i) {
      return _isSameDay(widget.startOfWeek.add(Duration(days: i)), _now);
    }).indexWhere((v) => v);

    if (todayIndex == -1) return const SizedBox();

    final minutes = _now.hour * 60 + _now.minute;
    final y = (minutes / 60) * widget.hourHeight;

    return SizedBox(
      height: widget.hourHeight * 24,
      child: Stack(
        children: [
          /// ───────── LIGNE ROUGE (PLEINE LARGEUR GRID) ─────────
          Positioned(
            top: y,
            left: 0,
            right: 0,
            child: Container(height: 0.5, color: const Color(0xFFDC2626)),
          ),

          /// ───────── POINT DANS LA COLONNE DU JOUR ─────────
        ],
      ),
    );
  }
}
