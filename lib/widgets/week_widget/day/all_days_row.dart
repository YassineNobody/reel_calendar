import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/all_day_event_item.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';

class AllDayGrid extends StatelessWidget {
  final DateTime startOfWeek;
  final double dayWidth;
  final int dayCount;
  final int maxSlots; // 👈 nombre max de slots à afficher
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const AllDayGrid({
    super.key,
    required this.startOfWeek,
    required this.dayWidth,
    required this.dayCount,
    required this.maxSlots,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  static const double _eventHeight = 22;
  static const double _spacing = 4;

  static const Color _weekendBackground = Color.fromARGB(
    137,
    238,
    238,
    238,
  ); // 👈 EXACTEMENT la même que TimeGridBackground

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dayWidth * dayCount,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(dayCount, (i) {
          final dayDate = startOfWeek.add(Duration(days: i));
          final events = eventController.allDayEventsForDay(dayDate);

          final isWeekend =
              dayDate.weekday == DateTime.saturday ||
              dayDate.weekday == DateTime.sunday;

          return Container(
            width: dayWidth,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              color: isWeekend ? _weekendBackground : null,
              border: const Border(
                top: BorderSide(color: Color(0xFFDFDFDF)),
                right: BorderSide(color: Color(0xFFDFDFDF)),
                bottom: BorderSide(color: Color(0xFFDFDFDF), width: 3),
              ),
            ),

            // ⬇️ AUCUN Listener GLOBAL ICI
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(maxSlots, (slotIndex) {
                // ───── EVENT ─────
                if (slotIndex < events.length) {
                  final event = events[slotIndex];

                  return AllDayEventItem(
                    onEventLinkTap: onEventLinkTap,
                    event: event,
                    controller: eventController,
                    height: _eventHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    margin: const EdgeInsets.only(bottom: _spacing),
                    onMenuAction: onMenuAction,
                  );
                }

                // ───── SLOT VIDE → MENU DAY ─────
                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) {
                    if ((e.buttons & kSecondaryMouseButton) != 0) {
                      final menuContext = CalendarMenuContext(
                        view: CalendarView.week,
                        target: CalendarMenuTarget.dayEmpty,
                        day: dayDate,
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
                  child: SizedBox(height: _eventHeight + _spacing),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
