import 'dart:async';
import 'package:flutter/widgets.dart';

class NowIndicatorDay extends StatefulWidget {
  final double hourHeight;
  final double dayWidth;
  final DateTime day;

  const NowIndicatorDay({
    super.key,
    required this.hourHeight,
    required this.dayWidth,
    required this.day,
  });

  @override
  State<NowIndicatorDay> createState() => _NowIndicatorDayState();
}

class _NowIndicatorDayState extends State<NowIndicatorDay> {
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
    // ❌ PAS LE JOUR J → RIEN
    if (!_isSameDay(widget.day, _now)) {
      return const SizedBox.shrink();
    }

    final minutes = _now.hour * 60 + _now.minute;
    final y = (minutes / 60) * widget.hourHeight;

    return SizedBox(
      width: widget.dayWidth,
      height: widget.hourHeight * 24,
      child: Stack(
        children: [
          /// ───────── LIGNE ROUGE ─────────
          Positioned(
            top: y,
            left: 0,
            right: 1,
            child: Container(height: 0.5, color: const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}
