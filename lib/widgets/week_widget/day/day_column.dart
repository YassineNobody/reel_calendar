import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/week_event_block.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';
import 'package:reel_calendar/utils/week_event_layout.dart';

class DayColumn extends StatelessWidget {
  final DateTime day;
  final double hourHeight;
  final double width;
  final bool isDayView;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const DayColumn({
    super.key,
    required this.day,
    required this.hourHeight,
    required this.width,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
    this.isDayView = false,
  });

  bool get _isToday {
    final now = DateTime.now();
    return now.year == day.year && now.month == day.month && now.day == day.day;
  }

  @override
  Widget build(BuildContext context) {
    final events = eventController.timedEventsForDay(day);
    final now = DateTime.now();
    final nowTop = hourToOffset(time: now, hourHeight: hourHeight);

    return SizedBox(
      width: width,
      height: hourHeight * 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ───── ZONE VIDE (GESTION MENU JOUR) ─────
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              if ((e.buttons & kSecondaryMouseButton) != 0) {
                final menuContext = CalendarMenuContext(
                  view: isDayView ? CalendarView.day : CalendarView.week,
                  target: events.isEmpty
                      ? CalendarMenuTarget.dayEmpty
                      : CalendarMenuTarget.dayWithEvents,
                  day: day,
                );

                openCalendarContextMenu<String>(
                  context: context,
                  clickPosition: e.position,
                  menuContext: menuContext,
                  onSelected: (value) {
                    onMenuAction?.call(value, menuContext);
                  },
                );
              }
            },
            child: Container(color: Colors.transparent),
          ),

          // ───── EVENTS (AU-DESSUS) ─────
          ...events.map((event) {
            final top = hourToOffset(time: event.start, hourHeight: hourHeight);

            final height = eventHeight(
              start: event.start,
              end: event.end,
              hourHeight: hourHeight,
            );

            return WeekEventBlock(
              onEventLinkTap: onEventLinkTap,
              isDayView: isDayView,
              event: event,
              top: top,
              height: height,
              controller: eventController,
              onMenuAction: onMenuAction, // 👈 IMPORTANT
            );
          }),

          // ───── POINT "MAINTENANT" ─────
          if (_isToday)
            Positioned(top: nowTop - 4, left: 0, child: const DayNowDot()),
        ],
      ),
    );
  }
}

class DayNowDot extends StatelessWidget {
  const DayNowDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFFFF3B30),
        shape: BoxShape.circle,
      ),
    );
  }
}
