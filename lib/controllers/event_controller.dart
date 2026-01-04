import 'package:flutter/foundation.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';

typedef WeekCallback = Future<void> Function(DateTime startOfWeek);
typedef MonthCallback = Future<void> Function(DateTime month);

class ReelCalendarEventController extends ChangeNotifier {
  // ───────── DATA ─────────
  final List<ReelCalendarEvent> _events = [];
  final Set<DateTime> _loadedWeeks = {};
  final Set<DateTime> _loadedMonths = {};

  ReelCalendarEvent? _selectedEvent;

  // ───────── CALLBACKS (EXTERNES) ─────────
  WeekCallback? onWeekChange;
  MonthCallback? onMonthChange;

  // ───────── GETTERS ─────────
  List<ReelCalendarEvent> get events => List.unmodifiable(_events);
  ReelCalendarEvent? get selectedEvent => _selectedEvent;

  bool isSelected(ReelCalendarEvent event) => _selectedEvent?.id == event.id;

  // ───────── FILTERING ─────────
  List<ReelCalendarEvent> timedEventsForDay(DateTime day) {
    return _events.where((e) => !e.allDay && e.occursOnDay(day)).toList();
  }

  List<ReelCalendarEvent> allDayEventsForDay(DateTime day) {
    return _events.where((e) => e.allDay && e.occursOnDay(day)).toList();
  }

  // ───────── SELECTION ─────────
  void selectEvent(ReelCalendarEvent event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedEvent != null) {
      _selectedEvent = null;
      notifyListeners();
    }
  }

  List<ReelCalendarEvent> eventsForMonth(DateTime month) {
    return _events
        .where(
          (e) => e.start.year == month.year && e.start.month == month.month,
        )
        .toList();
  }

  // ───────── PERIOD CHANGES ─────────
  Future<void> handleWeekChange(DateTime startOfWeek) async {
    // ─── WEEK ───
    if (!_loadedWeeks.contains(startOfWeek)) {
      if (onWeekChange != null) {
        await onWeekChange!(startOfWeek);
      }
      _loadedWeeks.add(startOfWeek);
    }

    // ─── MONTH(S) DÉDUITS ───
    final months = _monthsForWeek(startOfWeek);

    for (final month in months) {
      if (!_loadedMonths.contains(month)) {
        if (onMonthChange != null) {
          await onMonthChange!(month);
        }
        _loadedMonths.add(month);
      }
    }
  }

  Future<void> handleMonthChange(DateTime month) async {
    final key = DateTime(month.year, month.month);
    if (_loadedMonths.contains(key)) return;

    if (onMonthChange != null) {
      await onMonthChange!(key);
      _loadedMonths.add(key);
    }
  }

  // ───────── REFRESH ─────────
  Future<void> refetchWeek(DateTime startOfWeek) async {
    _loadedWeeks.remove(startOfWeek);

    _events.removeWhere((e) => _eventOccursInWeek(e, startOfWeek));

    await handleWeekChange(startOfWeek);
    notifyListeners();
  }

  // ───────── MUTATIONS (CRUD) ─────────
  void setEvents(List<ReelCalendarEvent> events) {
    _events
      ..clear()
      ..addAll(events);
    notifyListeners();
  }

  void addEvent(ReelCalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(ReelCalendarEvent updated) {
    _events.removeWhere((e) => e.id == updated.id);
    _events.add(updated);

    if (_selectedEvent?.id == updated.id) {
      _selectedEvent = updated;
    }

    notifyListeners();
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);

    if (_selectedEvent?.id == eventId) {
      _selectedEvent = null;
    }

    notifyListeners();
  }

  void clear() {
    _events.clear();
    _loadedWeeks.clear();
    _loadedMonths.clear();
    _selectedEvent = null;
    notifyListeners();
  }

  // ───────── HELPERS ─────────
  bool _eventOccursInWeek(ReelCalendarEvent event, DateTime startOfWeek) {
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (event.occursOnDay(day)) {
        return true;
      }
    }
    return false;
  }

  int maxAllDayEventsForWeek(DateTime startOfWeek) {
    int max = 0;
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final count = allDayEventsForDay(day).length;
      if (count > max) max = count;
    }
    return max;
  }

  int maxAllDayEventsForDay(DateTime day) {
    return allDayEventsForDay(day).length;
  }

  Set<DateTime> _monthsForWeek(DateTime startOfWeek) {
    final months = <DateTime>{};

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      months.add(DateTime(day.year, day.month));
    }

    return months;
  }
}
