import 'package:flutter/foundation.dart';
import 'package:reel_calendar/enums/calendar_view.dart';

class CalendarController extends ChangeNotifier {
  DateTime _currentDate;
  CalendarView _currentView = CalendarView.month;

  CalendarController({DateTime? initialDate})
    : _currentDate = _normalize(initialDate ?? DateTime.now());

  // ───────── NORMALISATION ─────────
  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _normalizeMonth(DateTime d) => DateTime(d.year, d.month, 1);

  // ───────── GETTERS ─────────
  DateTime get currentDate => _currentDate;
  CalendarView get currentView => _currentView;

  DateTime get currentMonth =>
      DateTime(_currentDate.year, _currentDate.month, 1);

  // ───────── VIEW MANAGEMENT (NOUVEAU) ─────────
  void setView(CalendarView view) {
    if (_currentView == view) return;
    _currentView = view;
    notifyListeners();
  }

  // ───────── DATE NAVIGATION ─────────
  void jumpTo(DateTime date) {
    final normalized = _normalize(date);
    if (_currentDate == normalized) return;

    _currentDate = normalized;
    notifyListeners();
  }

  void jumpToToday() {
    jumpTo(DateTime.now());
  }

  void jumpToCurrentMonth() {
    jumpToMonth(DateTime.now());
  }

  // ───────── DAY ─────────
  void nextDay() => jumpTo(_currentDate.add(const Duration(days: 1)));
  void previousDay() => jumpTo(_currentDate.subtract(const Duration(days: 1)));

  // ───────── WEEK ─────────
  void nextWeek() => jumpTo(_currentDate.add(const Duration(days: 7)));
  void previousWeek() => jumpTo(_currentDate.subtract(const Duration(days: 7)));

  DateTime get startOfWeek {
    final diff = _currentDate.weekday - DateTime.monday;
    return _currentDate.subtract(Duration(days: diff));
  }

  // ───────── MONTH ─────────
  void nextMonth() {
    jumpToMonth(DateTime(_currentDate.year, _currentDate.month + 1));
  }

  void previousMonth() {
    jumpToMonth(DateTime(_currentDate.year, _currentDate.month - 1));
  }

  void jumpToMonth(DateTime month) {
    final normalized = _normalizeMonth(month);
    if (currentMonth == normalized) return;

    _currentDate = normalized;
    notifyListeners();
  }
}
