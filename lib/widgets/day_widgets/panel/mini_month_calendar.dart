import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';

class MiniMonthGrid extends StatelessWidget {
  final CalendarController controller;
  final ReelCalendarEventController eventController;

  const MiniMonthGrid({
    super.key,
    required this.controller,
    required this.eventController,
  });

  static const double _cellWidth = 30;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.currentDate;
        final today = DateTime.now();

        final firstDayOfMonth = DateTime(current.year, current.month, 1);

        // Lundi de la première semaine affichée
        final startOffset = (firstDayOfMonth.weekday + 6) % 7;
        final gridStartDate = firstDayOfMonth.subtract(
          Duration(days: startOffset),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWeekdays(),
            const SizedBox(height: 2),
            SizedBox(
              width: _cellWidth * 7,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: 42, // 🔥 6 semaines fixes
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  final date = gridStartDate.add(Duration(days: index));

                  final isSelected = _isSameDay(date, controller.currentDate);
                  final isToday = _isSameDay(date, today);
                  final isCurrentMonth = date.month == current.month;

                  return GestureDetector(
                    onTap: () {
                      eventController.clearSelection();
                      controller.jumpTo(date);
                    },
                    child: _MiniDayCell(
                      day: date.day,
                      isSelected: isSelected,
                      isToday: isToday,
                      isOutsideMonth: !isCurrentMonth,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdays() {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return SizedBox(
      width: _cellWidth * 7,
      height: 15,
      child: Row(
        children: labels
            .map(
              (l) => SizedBox(
                width: _cellWidth,
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color.fromARGB(255, 131, 131, 131),
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MiniDayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isOutsideMonth;

  const _MiniDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isOutsideMonth,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isOutsideMonth
        ? Colors.black.withValues(alpha: 0.35)
        : (isToday ? const Color(0xFFDC2626) : Colors.black);

    return SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: isSelected
            ? Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFDC2626) : Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
