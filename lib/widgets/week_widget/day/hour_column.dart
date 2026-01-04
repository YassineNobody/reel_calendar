import 'package:flutter/widgets.dart';

class HourColumn extends StatelessWidget {
  final double hourHeight;
  final double width;
  final bool isCurrentWeek;
  final DateTime? displayedDay;

  const HourColumn({
    super.key,
    required this.hourHeight,
    required this.isCurrentWeek,
    this.displayedDay,
    this.width = 60,
  });

  static const int hideThresholdMinutes = 15;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    /// 👇 AJOUT LOGIQUE
    final bool isToday = displayedDay != null && _isSameDay(now, displayedDay!);

    return SizedBox(
      width: width,
      child: Column(
        children: List.generate(24, (hour) {
          final hourMinutes = hour * 60;
          final diff = (nowMinutes - hourMinutes).abs();

          /// ✅ WeekView → isCurrentWeek
          /// ✅ DayView  → displayedDay == today
          final bool shouldHide =
              (isCurrentWeek || isToday) && diff < hideThresholdMinutes;

          return SizedBox(
            height: hourHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Align(
                alignment: Alignment.topRight,
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: shouldHide
                      ? const SizedBox.shrink()
                      : Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
