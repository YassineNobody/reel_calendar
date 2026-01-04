import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/widgets/month_widgets/grid/month_grid.dart';
import 'package:reel_calendar/widgets/month_widgets/grid/week_days_rows.dart';
import 'package:reel_calendar/widgets/month_widgets/header/header_month.dart';
import 'package:reel_calendar/widgets/week_widget/navigator/week_switcher.dart';

class MonthView extends StatefulWidget {
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const MonthView({
    super.key,
    required this.calendarController,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  static const int _baseIndex = 10000;

  late final PageController _pageController;

  /// 🔑 DATE ANCRE (IMMUTABLE)
  late final DateTime _anchorMonth;
  late DateTime _lastHandledMonth;

  @override
  void initState() {
    super.initState();

    _lastHandledMonth = DateTime(
      widget.calendarController.currentDate.year,
      widget.calendarController.currentDate.month,
      1,
    );

    widget.calendarController.addListener(_onCalendarChanged);

    _anchorMonth = DateTime(
      widget.calendarController.currentDate.year,
      widget.calendarController.currentDate.month,
      1,
    );

    _pageController = PageController(initialPage: _baseIndex);
  }

  void _onCalendarChanged() {
    final current = widget.calendarController.currentDate;
    final month = DateTime(current.year, current.month, 1);

    if (month != _lastHandledMonth) {
      _lastHandledMonth = month;
      widget.eventController.handleMonthChange(month);
    }
  }

  /// 🔑 mois = ancre + offset
  DateTime _monthForIndex(int index) {
    final offset = index - _baseIndex;
    return DateTime(_anchorMonth.year, _anchorMonth.month + offset, 1);
  }

  int _indexForMonth(DateTime month) {
    final diffMonths =
        (month.year - _anchorMonth.year) * 12 +
        (month.month - _anchorMonth.month);

    return _baseIndex + diffMonths;
  }

  @override
  void dispose() {
    widget.calendarController.removeListener(_onCalendarChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.calendarController,
        widget.eventController, // 👈 IMPORTANT
      ]),
      builder: (context, _) {
        final currentMonth = DateTime(
          widget.calendarController.currentDate.year,
          widget.calendarController.currentDate.month,
          1,
        );

        // 🔁 sync controller → PageView
        final targetIndex = _indexForMonth(currentMonth);

        if (_pageController.hasClients &&
            _pageController.page?.round() != targetIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          });
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // ───────── HEADER FIXE ─────────
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MonthHeader(month: currentMonth),
                    WeekSwitcher(
                      onPrevious: widget.calendarController.previousMonth,
                      onToday: widget.calendarController.jumpToCurrentMonth,
                      onNext: widget.calendarController.nextMonth,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              const WeekDaysRow(),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color.fromARGB(86, 0, 0, 0),
              ),

              // ───────── SWIPE SUR LA GRID ─────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,

                  // 🔁 swipe → controller
                  onPageChanged: (index) {
                    final newMonth = _monthForIndex(index);
                    widget.calendarController.jumpToMonth(newMonth);
                  },

                  itemBuilder: (context, index) {
                    final monthDate = _monthForIndex(index);

                    return MonthGrid(
                      onMenuAction: widget.onMenuAction,
                      month: monthDate,
                      eventController: widget.eventController,
                      calendarController: widget.calendarController,
                      onEventLinkTap: widget.onEventLinkTap,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
