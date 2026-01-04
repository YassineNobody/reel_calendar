import 'package:flutter/material.dart';
import 'package:reel_calendar/reel_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(String value) async {
  final uri = Uri.parse(value);

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!ok) {
    debugPrint('❌ Impossible d’ouvrir $value');
  }
}

void main() {
  final calendarController = CalendarController();
  final eventController = ReelCalendarEventController();

  final now = DateTime.now();

  // ───────── EVENTS DE TEST ─────────
  eventController.setEvents([
    ReelCalendarEvent(
      id: '1',
      title: 'Jour férié avec un titre tres long juste pour tester',
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day + 1),
      allDay: true,
      description: '',
      typesEvent: [TypeEvent(color: Colors.red, name: "Fêtes (France)")],
      eventLink: EventLink(
        label: 'google',
        type: EventLinkType.zoom,
        value: 'https://en.wikipedia.org/wiki/Google_logo',
      ),
    ),
    ReelCalendarEvent(
      id: '4',
      title: 'Jour plus',
      start: DateTime(now.year, now.month, now.day + 1),
      end: DateTime(now.year, now.month, now.day + 2),
      allDay: true,
      typesEvent: [TypeEvent(color: Colors.red, name: "Fêtes (France)")],
      description: '',
    ),
    ReelCalendarEvent(
      id: '3',
      title: 'Call sometime I am sad',
      description:
          'petite description ici tres rapide et un peu longue pour ajuster le style si possible a voir. \ndemain on verra le soleil se coucher doucement a l\'aurore de nos jours glorieux',
      start: DateTime(now.year, now.month, now.day, 17),
      end: DateTime(now.year, now.month, now.day, 18),
      typesEvent: [TypeEvent(color: Colors.green, name: 'yassine@gmail.com')],
      allDay: false,
    ),

    ReelCalendarEvent(
      id: '5',
      title: 'Call my mon',
      description: 'petite description ici tres rapide',
      start: DateTime(2026, 1, 5, 10, 30),
      end: DateTime(2026, 01, 5, 10, 35),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.green, name: 'yassine@gmail.com')],
    ),
  ]);
  // ───────── CALLBACKS DE TEST ─────────
  eventController.onWeekChange = (startOfWeek) async {
    debugPrint('🟢 onWeekChange → $startOfWeek');
    // pour l’instant : on ne fetch rien
    // plus tard : API / DB / cache
  };

  eventController.onMonthChange = (month) async {
    debugPrint('🟣 onMonthChange → $month');
  };

  calendarController.setView(CalendarView.month);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ReelCalendar(
            onEventLinkTap: (event, link) {
              openLink(link.value);
            },
            calendarController: calendarController,
            eventController: eventController,
            onMenuAction: (action, context) {
              debugPrint(action);
            },
          ),
        ),
      ),
    ),
  );
}
