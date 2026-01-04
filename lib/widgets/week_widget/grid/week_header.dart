import 'package:flutter/widgets.dart';

class WeekHeader extends StatelessWidget {
  final DateTime startOfWeek;
  final double dayWidth;
  final double hourColumnWidth;
  final double height;

  const WeekHeader({
    super.key,
    required this.startOfWeek,
    required this.dayWidth,
    required this.hourColumnWidth,
    this.height = 48,
  });

  static const List<String> _weekdays = [
    'lun.',
    'mar.',
    'mer.',
    'jeu.',
    'ven.',
    'sam.',
    'dim.',
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalWidth = hourColumnWidth + dayWidth * 7;

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Row(
        children: [
          /// ⏰ espace colonne heures
          SizedBox(width: hourColumnWidth),

          /// 📅 jours
          Row(
            children: List.generate(7, (i) {
              final day = startOfWeek.add(Duration(days: i));
              final isToday = _isSameDay(day, today);

              return SizedBox(
                width: dayWidth,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// jour (lun.)
                      Text(
                        _weekdays[i],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0), // gris Google
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(width: 3),

                      /// numéro (22) — style Google Calendar
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: isToday
                            ? const BoxDecoration(
                                color: Color(0xFFDC2626), // rouge
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,

                            color: isToday
                                ? const Color(0xFFFFFFFF) // blanc
                                : const Color(0xFF111827), // noir
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
