import 'package:flutter/widgets.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/utils/now_label.dart';
import 'package:reel_calendar/widgets/day_widgets/grid/all_day_grid_by_day.dart';
import 'package:reel_calendar/widgets/day_widgets/header/header_day.dart';
import 'package:reel_calendar/widgets/day_widgets/indicator/indicator_now_day.dart';
import 'package:reel_calendar/widgets/week_widget/day/day_column.dart';
import 'package:reel_calendar/widgets/week_widget/day/hour_column.dart';
import 'package:reel_calendar/widgets/week_widget/grid/background_grid.dart';

class DayViewWidget extends StatefulWidget {
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const DayViewWidget({
    super.key,
    required this.calendarController,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  State<DayViewWidget> createState() => _DayViewState();
}

class _DayViewState extends State<DayViewWidget>
    with SingleTickerProviderStateMixin {
  static const double hourHeight = 48;
  static const double hourColumnWidth = 105;
  static const double swipeThreshold = 120;
  static const double topInset = 6;

  double _dragDx = 0;
  bool get _isSwiping => _dragDx != 0;

  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  late final ScrollController _verticalScrollController;
  bool _initialScrollDone = false;

  DateTime? _lastWeekStart;
  DateTime? _lastMonth;

  @override
  void initState() {
    super.initState();
    _lastWeekStart = widget.calendarController.startOfWeek;
    _lastMonth = DateTime(
      widget.calendarController.currentDate.year,
      widget.calendarController.currentDate.month,
      1,
    );

    widget.calendarController.addListener(_onCalendarChanged);
    _verticalScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(_scrollToNowIfNeeded);
    });

    _snapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 340),
        )..addListener(() {
          setState(() {
            _dragDx = _snapAnimation?.value ?? _dragDx;
          });
        });
  }

  void _onCalendarChanged() {
    final calendar = widget.calendarController;
    final currentDay = calendar.currentDate;

    final weekStart = calendar.startOfWeek;
    if (_lastWeekStart != weekStart) {
      _lastWeekStart = weekStart;
      widget.eventController.handleWeekChange(weekStart);
    }

    final month = DateTime(currentDay.year, currentDay.month, 1);
    if (_lastMonth != month) {
      _lastMonth = month;
      widget.eventController.handleMonthChange(month);
    }
  }

  @override
  void dispose() {
    widget.calendarController.removeListener(_onCalendarChanged);

    _snapController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _scrollToNowIfNeeded() {
    if (_initialScrollDone) return;
    if (!_verticalScrollController.hasClients) return;

    final position = _verticalScrollController.position;
    if (position.viewportDimension == 0) return;

    final now = DateTime.now();
    final day = widget.calendarController.currentDate;

    if (DateTime(now.year, now.month, now.day) !=
        DateTime(day.year, day.month, day.day)) {
      return;
    }

    final minutes = now.hour * 60 + now.minute;
    final targetOffset =
        (minutes / 60) * hourHeight - position.viewportDimension / 2;

    _verticalScrollController.jumpTo(
      targetOffset.clamp(0, position.maxScrollExtent),
    );

    _initialScrollDone = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _snapController.stop();
    setState(() {
      _dragDx += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double gridWidth) {
    final shouldChangeDay = _dragDx.abs() > swipeThreshold;

    final targetDx = shouldChangeDay
        ? (_dragDx < 0 ? -gridWidth : gridWidth)
        : 0;

    _snapAnimation = Tween<double>(begin: _dragDx, end: targetDx.toDouble())
        .animate(
          CurvedAnimation(parent: _snapController, curve: Curves.easeOutQuart),
        );

    _snapController.forward(from: 0).whenComplete(() {
      if (shouldChangeDay) {
        _dragDx < 0
            ? widget.calendarController.nextDay()
            : widget.calendarController.previousDay();
      }
      setState(() => _dragDx = 0);
    });
  }

  Widget _buildGrid({required DateTime day, required double dayWidth}) {
    return SizedBox(
      width: dayWidth,
      child: Stack(
        children: [
          TimeGridBackground(
            startOfWeek: day,
            dayCount: 1,
            dayWidth: dayWidth,
            hourHeight: hourHeight,
            showLeftBorder: _isSwiping,
          ),

          NowIndicatorDay(hourHeight: hourHeight, dayWidth: dayWidth, day: day),
          DayColumn(
            onEventLinkTap: widget.onEventLinkTap,
            onMenuAction: widget.onMenuAction,
            isDayView: true,
            day: day,
            hourHeight: hourHeight,
            width: dayWidth,
            eventController: widget.eventController,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.calendarController,
      builder: (context, _) {
        final currentDay = widget.calendarController.currentDate;

        final targetDay = _dragDx < 0
            ? currentDay.add(const Duration(days: 1))
            : currentDay.subtract(const Duration(days: 1));
        final now = DateTime.now();
        final isToday =
            now.year == currentDay.year &&
            now.month == currentDay.month &&
            now.day == currentDay.day;

        final maxSlots = widget.eventController.maxAllDayEventsForDay(
          currentDay,
        );

        return GestureDetector(
          onTap: () {
            widget.eventController.clearSelection();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dayWidth = constraints.maxWidth - hourColumnWidth;
              final currentX = _dragDx;
              final targetX = _dragDx < 0
                  ? _dragDx + dayWidth
                  : _dragDx - dayWidth;

              return Column(
                children: [
                  HeaderDay(currentDay: currentDay),

                  // ALL DAY ROW (COPIE EXACTE DE WEEKVIEW MAIS 1 JOUR)
                  Row(
                    children: [
                      SizedBox(
                        width: hourColumnWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'toute la journée',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRect(
                          child: Stack(
                            children: [
                              if (_isSwiping)
                                Transform.translate(
                                  offset: Offset(targetX, 0),
                                  child: AllDayGridDay(
                                    onEventLinkTap: widget.onEventLinkTap,
                                    maxSlots: maxSlots == 0 ? 1 : maxSlots,
                                    eventController: widget.eventController,
                                    day: targetDay,
                                    width: dayWidth,
                                    onMenuAction: widget.onMenuAction,
                                  ),
                                ),
                              Transform.translate(
                                offset: Offset(currentX, 0),
                                child: AllDayGridDay(
                                  onEventLinkTap: widget.onEventLinkTap,
                                  maxSlots: maxSlots == 0 ? 1 : maxSlots,
                                  eventController: widget.eventController,
                                  day: currentDay,
                                  width: dayWidth,
                                  onMenuAction: widget.onMenuAction,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // GRID HEURES (COPIE WEEKVIEW → 1 JOUR)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      padding: const EdgeInsets.only(top: topInset),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: hourColumnWidth,
                            height: hourHeight * 24,
                            child: Stack(
                              children: [
                                HourColumn(
                                  hourHeight: hourHeight,
                                  width: hourColumnWidth,
                                  isCurrentWeek: false,
                                  displayedDay: currentDay,
                                ),

                                if (isToday)
                                  buildNowTimeLabel(
                                    true,
                                    hourHeight,
                                    hourColumnWidth,
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: _onHorizontalDragUpdate,
                              onHorizontalDragEnd: (d) =>
                                  _onHorizontalDragEnd(d, dayWidth),
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    if (_isSwiping)
                                      Transform.translate(
                                        offset: Offset(targetX, 0),
                                        child: _buildGrid(
                                          day: targetDay,
                                          dayWidth: dayWidth,
                                        ),
                                      ),
                                    Transform.translate(
                                      offset: Offset(currentX, 0),
                                      child: _buildGrid(
                                        day: currentDay,
                                        dayWidth: dayWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
