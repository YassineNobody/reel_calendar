import 'package:flutter/widgets.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/widgets/day_widgets/day_widget.dart';
import 'package:reel_calendar/widgets/day_widgets/panel/event_panel.dart';
import 'package:reel_calendar/widgets/day_widgets/panel/mini_month_calendar.dart';
import 'package:reel_calendar/widgets/week_widget/navigator/week_switcher.dart';

class DayView extends StatelessWidget {
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const DayView({
    super.key,
    required this.calendarController,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  static const double _panelBreakpoint = 420;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ───────── PLANNING ─────────
        Expanded(
          flex: 2,
          child: DayViewWidget(
            onEventLinkTap: onEventLinkTap,
            calendarController: calendarController,
            eventController: eventController,
            onMenuAction: onMenuAction,
          ),
        ),

        // ───────── PANNEAU LATÉRAL ─────────
        Expanded(
          flex: 1,
          child: Container(
            color: const Color.fromARGB(255, 242, 233, 233),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < _panelBreakpoint;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 15,
                  ),
                  child: isCompact
                      ? _buildVerticalPanel()
                      : _buildHorizontalPanel(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ───────── PANEL LARGE ─────────
  Widget _buildHorizontalPanel() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MiniMonthGrid(
              controller: calendarController,
              eventController: eventController,
            ),
            WeekSwitcher(
              onPrevious: () {
                eventController.clearSelection();
                calendarController.previousDay();
              },
              onToday: () {
                eventController.clearSelection();
                calendarController.jumpToToday();
              },
              onNext: () {
                eventController.clearSelection();
                calendarController.nextDay();
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ⚠️ Flexible OK ici car la Column a une hauteur FINIE
        Flexible(
          fit: FlexFit.loose,
          child: SelectedEventPanel(
            controller: eventController,
            onEventLinkTap: onEventLinkTap,
          ),
        ),
      ],
    );
  }

  // ───────── PANEL COMPACT ─────────
  Widget _buildVerticalPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: WeekSwitcher(
            onPrevious: () {
              eventController.clearSelection();
              calendarController.previousDay();
            },
            onToday: () {
              eventController.clearSelection();
              calendarController.jumpToToday();
            },
            onNext: () {
              eventController.clearSelection();
              calendarController.nextDay();
            },
          ),
        ),
        const SizedBox(height: 12),
        MiniMonthGrid(
          controller: calendarController,
          eventController: eventController,
        ),

        Flexible(
          fit: FlexFit.loose,
          child: SelectedEventPanel(
            controller: eventController,
            onEventLinkTap: onEventLinkTap,
          ),
        ),
      ],
    );
  }
}
