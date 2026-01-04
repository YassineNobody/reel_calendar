import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/all_day_event_item.dart';

class AllDayGridDay extends StatelessWidget {
  final DateTime day;
  final double width;
  final int maxSlots;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;
  const AllDayGridDay({
    super.key,
    required this.day,
    required this.width,
    required this.maxSlots,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  static const double _eventHeight = 22;
  static const double _spacing = 4;

  static const Color _weekendBackground = Color.fromARGB(137, 238, 238, 238);

  @override
  Widget build(BuildContext context) {
    final events = eventController.allDayEventsForDay(day);

    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: isWeekend ? _weekendBackground : null,
          border: const Border(
            top: BorderSide(color: Color(0xFFDFDFDF)),
            bottom: BorderSide(color: Color(0xFFDFDFDF), width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(maxSlots, (slotIndex) {
            if (slotIndex < events.length) {
              final event = events[slotIndex];
              return AllDayEventItem(
                onEventLinkTap: onEventLinkTap,
                isDayView: true,
                event: event,
                controller: eventController,
                height: _eventHeight,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                margin: const EdgeInsets.only(bottom: _spacing),
                onMenuAction: onMenuAction,
              );
            }

            // 👇 slot vide → réserve l’espace (alignement)
            return SizedBox(height: _eventHeight + _spacing);
          }),
        ),
      ),
    );
  }
}
