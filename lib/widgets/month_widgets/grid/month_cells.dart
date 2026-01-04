import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';

class MonthDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isOutsideMonth;
  final int weekday;
  final List<ReelCalendarEvent> events;
  final DateTime date;
  final bool isSelected;

  /// Action logique (ouvrir popup du jour)
  final VoidCallback? onDayTap;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;

  const MonthDayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isOutsideMonth,
    required this.weekday,
    required this.events,
    required this.date,
    required this.isSelected,
    required this.onMenuAction,
    this.onDayTap,
  });

  static const Color _weekendColor = Color.fromARGB(137, 238, 238, 238);

  @override
  Widget build(BuildContext context) {
    final bool isWeekend =
        weekday == DateTime.saturday || weekday == DateTime.sunday;

    final Color textColor = isOutsideMonth
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black;

    final bool hasEvents = events.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          // ───── CLIC DROIT ─────
          if ((e.buttons & kSecondaryMouseButton) != 0) {
            final menuTarget = events.isEmpty
                ? CalendarMenuTarget.dayEmpty
                : CalendarMenuTarget.dayWithEvents;
            final menuContext = CalendarMenuContext(
              view: CalendarView.month,
              target: menuTarget,
              day: date,
            );
            openCalendarContextMenu<String>(
              context: context,
              clickPosition: e.position,
              menuContext: menuContext,
              onSelected: (value) {
                if (value == 'openDay') {
                  onDayTap?.call();
                } else {
                  onMenuAction?.call(value, menuContext);
                }
              },
            );
          }
          // ───── CLIC GAUCHE ─────
          else if ((e.buttons & kPrimaryButton) != 0) {
            if (hasEvents) {
              onDayTap?.call();
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isWeekend ? _weekendColor : Colors.transparent,
            border: const Border(
              right: BorderSide(color: Color.fromARGB(31, 0, 0, 0), width: 0.5),
              bottom: BorderSide(
                color: Color.fromARGB(31, 0, 0, 0),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            children: [
              // ───── DAY NUMBER ─────
              Positioned(
                top: 0,
                right: 0,
                child: _DayNumber(day: day, isToday: isToday, color: textColor),
              ),

              // ───── EVENT COUNT ─────
              if (hasEvents)
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: _EventCountBadge(
                    count: events.length,
                    isSelected: isSelected,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _EventCountBadge({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  final int day;
  final bool isToday;
  final Color color;

  const _DayNumber({
    required this.day,
    required this.isToday,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFDC2626),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Text(
      '$day',
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w400),
    );
  }
}
