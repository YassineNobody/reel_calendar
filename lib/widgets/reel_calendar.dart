import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/views/day_view.dart';
import 'package:reel_calendar/views/month_view.dart';
import 'package:reel_calendar/views/week_view.dart';

class ReelCalendar extends StatelessWidget {
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const ReelCalendar({
    super.key,
    required this.calendarController,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: calendarController,
      builder: (context, _) {
        switch (calendarController.currentView) {
          case CalendarView.day:
            return DayView(
              calendarController: calendarController,
              eventController: eventController,
              onMenuAction: onMenuAction,
              onEventLinkTap: onEventLinkTap,
            );

          case CalendarView.week:
            return WeekView(
              calendarController: calendarController,
              eventController: eventController,
              onMenuAction: onMenuAction,
              onEventLinkTap: onEventLinkTap,
            );

          case CalendarView.month:
            return MonthView(
              onMenuAction: onMenuAction,
              calendarController: calendarController,
              eventController: eventController,
              onEventLinkTap: onEventLinkTap,
            );
        }
      },
    );
  }
}
