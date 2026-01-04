import 'package:flutter/widgets.dart';
import 'package:reel_calendar/controllers/calendar_controller.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/utils/now_label.dart';
import 'package:reel_calendar/widgets/week_widget/day/all_days_row.dart';
import 'package:reel_calendar/widgets/week_widget/day/day_column.dart';
import 'package:reel_calendar/widgets/week_widget/day/hour_column.dart';
import 'package:reel_calendar/widgets/week_widget/day/now_indicator.dart';
import 'package:reel_calendar/widgets/week_widget/grid/background_grid.dart';
import 'package:reel_calendar/widgets/week_widget/grid/week_header.dart';
import 'package:reel_calendar/widgets/week_widget/week/header_month.dart';

class WeekView extends StatefulWidget {
  final CalendarController calendarController;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const WeekView({
    super.key,
    required this.calendarController,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView>
    with SingleTickerProviderStateMixin {
  // ───────── CONSTANTES ─────────
  static const double hourHeight = 50;
  static const double hourColumnWidth = 105;
  static const double swipeThreshold = 120;
  static const double topInset = 6;

  // ───────── ÉTAT ─────────
  double _dragDx = 0;
  bool get _isSwiping => _dragDx != 0;

  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  // 👇 SCROLL VERTICAL
  late final ScrollController _verticalScrollController;
  bool _initialScrollDone = false;

  late DateTime _lastHandledWeek;
  void _onCalendarChange() {
    final newWeek = widget.calendarController.startOfWeek;

    if (newWeek != _lastHandledWeek) {
      _lastHandledWeek = newWeek;

      widget.eventController.handleWeekChange(newWeek);
    }
  }

  @override
  void initState() {
    super.initState();

    _verticalScrollController = ScrollController();
    _lastHandledWeek = widget.calendarController.startOfWeek;

    widget.calendarController.addListener(_onCalendarChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // on attend que tout soit réellement posé
      widget.eventController.handleWeekChange(
        widget.calendarController.startOfWeek,
      );

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

  @override
  void dispose() {
    widget.calendarController.removeListener(_onCalendarChange);
    _snapController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // ───────── SCROLL INIT ─────────
  void _scrollToNowIfNeeded() {
    if (_initialScrollDone) return;
    if (!_verticalScrollController.hasClients) return;

    final position = _verticalScrollController.position;

    // ⛔️ layout pas encore prêt
    if (position.viewportDimension == 0) return;

    final now = DateTime.now();
    final currentWeek = widget.calendarController.startOfWeek;

    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      currentWeek.year,
      currentWeek.month,
      currentWeek.day,
    );
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));

    final isCurrentWeek = !today.isBefore(start) && !today.isAfter(end);
    if (!isCurrentWeek) return;

    final minutes = now.hour * 60 + now.minute;

    // 🎯 position cible centrée sur l’heure actuelle
    final targetOffset =
        (minutes / 60) * hourHeight - position.viewportDimension / 2;

    _verticalScrollController.jumpTo(
      targetOffset.clamp(0, position.maxScrollExtent),
    );

    _initialScrollDone = true;
  }

  // ───────── DRAG ─────────
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _snapController.stop();
    setState(() {
      _dragDx += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double gridWidth) {
    final bool shouldChangeWeek = _dragDx.abs() > swipeThreshold;

    final double targetDx = shouldChangeWeek
        ? (_dragDx < 0 ? -gridWidth : gridWidth)
        : 0;

    _snapAnimation = Tween<double>(begin: _dragDx, end: targetDx).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutQuart),
    );

    _snapController.forward(from: 0).whenComplete(() {
      if (shouldChangeWeek) {
        _dragDx < 0
            ? widget.calendarController.nextWeek()
            : widget.calendarController.previousWeek();
      }

      setState(() => _dragDx = 0);
    });
  }

  // ───────── GRID ─────────
  Widget _buildGrid({
    required DateTime startOfWeek,
    required int dayCount,
    required double dayWidth,
  }) {
    return SizedBox(
      width: dayWidth * dayCount,
      child: Stack(
        children: [
          TimeGridBackground(
            startOfWeek: startOfWeek,
            dayCount: dayCount,
            dayWidth: dayWidth,
            hourHeight: hourHeight,
            showLeftBorder: _isSwiping,
          ),
          NowIndicator(
            hourHeight: hourHeight,
            dayWidth: dayWidth,
            startOfWeek: startOfWeek,
          ),
          Row(
            children: List.generate(
              dayCount,
              (i) => DayColumn(
                onMenuAction: widget.onMenuAction,
                day: startOfWeek.add(Duration(days: i)),
                hourHeight: hourHeight,
                width: dayWidth,
                eventController: widget.eventController,
                onEventLinkTap: widget.onEventLinkTap,
              ),
            ),
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
        final currentWeek = widget.calendarController.startOfWeek;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final start = DateTime(
          currentWeek.year,
          currentWeek.month,
          currentWeek.day,
        );

        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        final maxAllDayCount = widget.eventController.maxAllDayEventsForWeek(
          currentWeek,
        );

        final isCurrentWeek = !today.isBefore(start) && !today.isAfter(end);

        return GestureDetector(
          onTap: () {
            widget.eventController.clearSelection();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              const int dayCount = 7;
              const double minDayWidth = 100;

              final availableWidth = constraints.maxWidth - hourColumnWidth;
              final dayWidth = (availableWidth / dayCount).clamp(
                minDayWidth,
                double.infinity,
              );

              final gridWidth = dayWidth * dayCount;
              final headerWidth = hourColumnWidth + gridWidth;

              final targetWeek = _dragDx < 0
                  ? currentWeek.add(const Duration(days: 7))
                  : currentWeek.subtract(const Duration(days: 7));

              final currentX = _dragDx;
              final targetX = _dragDx < 0
                  ? _dragDx + gridWidth
                  : _dragDx - gridWidth;

              return Column(
                children: [
                  // ───────── HEADER ─────────
                  HeaderMonth(
                    controller: widget.calendarController,
                    currentWeek: currentWeek,
                  ),

                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: (d) =>
                        _onHorizontalDragEnd(d, gridWidth),
                    child: SizedBox(
                      height: 48,
                      child: ClipRect(
                        child: Stack(
                          children: [
                            if (_isSwiping)
                              Transform.translate(
                                offset: Offset(targetX, 0),
                                child: SizedBox(
                                  width: headerWidth,
                                  child: WeekHeader(
                                    startOfWeek: targetWeek,
                                    dayWidth: dayWidth,
                                    hourColumnWidth: hourColumnWidth,
                                  ),
                                ),
                              ),
                            Transform.translate(
                              offset: Offset(currentX, 0),
                              child: SizedBox(
                                width: headerWidth,
                                child: WeekHeader(
                                  startOfWeek: currentWeek,
                                  dayWidth: dayWidth,
                                  hourColumnWidth: hourColumnWidth,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🟢 ───────── ALL DAY ROW (FIXE) ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ───── LABEL FIXE ─────
                      SizedBox(
                        width: hourColumnWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Align(
                            alignment: Alignment.topRight,
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

                      // ───── PARTIE SWIPABLE ─────
                      Expanded(
                        child: ClipRect(
                          child: Stack(
                            children: [
                              if (_isSwiping)
                                Transform.translate(
                                  offset: Offset(targetX, 0),
                                  child: AllDayGrid(
                                    startOfWeek: targetWeek,
                                    dayWidth: dayWidth,
                                    dayCount: dayCount,
                                    maxSlots: maxAllDayCount == 0
                                        ? 1
                                        : maxAllDayCount,
                                    eventController: widget.eventController,
                                    onMenuAction: widget.onMenuAction,
                                    onEventLinkTap: widget.onEventLinkTap,
                                  ),
                                ),

                              Transform.translate(
                                offset: Offset(currentX, 0),
                                child: AllDayGrid(
                                  onEventLinkTap: widget.onEventLinkTap,
                                  startOfWeek: currentWeek,
                                  dayWidth: dayWidth,
                                  dayCount: dayCount,
                                  maxSlots: maxAllDayCount == 0
                                      ? 1
                                      : maxAllDayCount,
                                  eventController: widget.eventController,
                                  onMenuAction: widget.onMenuAction,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ───────── CONTENU ─────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _verticalScrollController, // 👈 ICI
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
                                  isCurrentWeek: isCurrentWeek,
                                ),
                                buildNowTimeLabel(
                                  isCurrentWeek,
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
                                  _onHorizontalDragEnd(d, gridWidth),
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    if (_isSwiping)
                                      Transform.translate(
                                        offset: Offset(targetX, 0),
                                        child: _buildGrid(
                                          startOfWeek: targetWeek,
                                          dayCount: dayCount,
                                          dayWidth: dayWidth,
                                        ),
                                      ),
                                    Transform.translate(
                                      offset: Offset(currentX, 0),
                                      child: _buildGrid(
                                        startOfWeek: currentWeek,
                                        dayCount: dayCount,
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
