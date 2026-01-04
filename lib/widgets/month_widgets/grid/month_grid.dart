import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/popup_events_month.dart';

import 'package:reel_calendar/widgets/month_widgets/grid/month_cells.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const MonthGrid({
    super.key,
    required this.month,
    required this.eventController,
    required this.calendarController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startOffset = (firstDayOfMonth.weekday + 6) % 7;
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: startOffset));

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellHeight = constraints.maxHeight / 6;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 42,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: cellHeight,
          ),
          itemBuilder: (context, index) {
            final date = gridStartDate.add(Duration(days: index));

            final eventsForDay = [
              ...eventController.allDayEventsForDay(date),
              ...eventController.timedEventsForDay(date),
            ];

            return MonthDayCell(
              onMenuAction: onMenuAction,
              day: date.day,
              isToday: _isSameDay(date, DateTime.now()),
              isOutsideMonth: date.month != month.month,
              weekday: date.weekday,
              events: eventsForDay,
              date: date,
              onDayTap: () {
                calendarController.jumpTo(date);
                openDayEventsModal(context, date, eventController);
              },
              isSelected: _isSameDay(date, calendarController.currentDate),
            );
          },
        );
      },
    );
  }

  void openDayEventsModal(
    BuildContext context,
    DateTime day,
    ReelCalendarEventController eventController,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DayEvents',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return DayEventsModal(
          day: day,
          eventController: eventController,
          onMenuAction: onMenuAction,
          onEventLinkTap: onEventLinkTap,
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curve = Curves.easeOut;

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: child,
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
