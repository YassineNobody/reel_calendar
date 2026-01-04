import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reel_calendar/utils/format_month.dart';

class HeaderDay extends StatelessWidget {
  final DateTime currentDay;
  const HeaderDay({super.key, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 👈 alignement gauche
          children: [
            Text(
              formatDay(day: currentDay),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.6, // 👈 idéal pour gros titre
              ),
            ),
            Text(
              formatWeekday(day: currentDay),
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF6B7280),
                letterSpacing: -0.2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
