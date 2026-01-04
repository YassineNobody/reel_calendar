import 'package:flutter/widgets.dart';
import 'package:reel_calendar/reel_calendar.dart';
import 'package:reel_calendar/utils/format_month.dart';
import 'package:reel_calendar/widgets/week_widget/navigator/week_switcher.dart';

class HeaderMonth extends StatelessWidget {
  final CalendarController controller;
  final DateTime currentWeek;

  const HeaderMonth({
    super.key,
    required this.controller,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            formatMonthYear(currentWeek),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(width: 8),
          WeekSwitcher(
            onPrevious: controller.previousWeek,
            onToday: controller.jumpToToday,
            onNext: controller.nextWeek,
          ),
        ],
      ),
    );
  }
}
