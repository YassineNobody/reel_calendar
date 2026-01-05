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
  final coranEvents = [
    // ───── JANVIER 2026 : LECTURE DU CORAN (OCCURRENCES) ─────
    ReelCalendarEvent(
      id: '9512b042-9570-4ac5-97bf-ac883f8f93be',
      title: 'Lecture du Coran',
      description: 'Lecture quotidienne après fajr',
      start: DateTime(2026, 1, 1, 5, 30),
      end: DateTime(2026, 1, 1, 6, 0),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.deepPurple, name: 'Rituels')],
    ),
    ReelCalendarEvent(
      id: 'f5d886bc-2140-4898-b0bc-e316bb5a692f',
      title: 'Lecture du Coran',
      description: 'Lecture quotidienne après fajr',
      start: DateTime(2026, 1, 2, 5, 30),
      end: DateTime(2026, 1, 2, 6, 0),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.deepPurple, name: 'Rituels')],
    ),
    ReelCalendarEvent(
      id: '2457424e-2623-4cfe-9a85-36d140bb6ef7',
      title: 'Lecture du Coran',
      description: 'Lecture quotidienne après fajr',
      start: DateTime(2026, 1, 3, 5, 30),
      end: DateTime(2026, 1, 3, 6, 0),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.deepPurple, name: 'Rituels')],
    ),

    // 👉 tu continues exactement sur le même modèle
  ];

  // ───────── EVENTS DE TEST ─────────
  eventController.setEvents([
    // ───── EVENTS ALL-DAY EXISTANTS ─────
    ReelCalendarEvent(
      id: '1',
      title: 'Jour férié avec un titre tres long juste pour tester',
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day + 1),
      allDay: true,
      description: '',
      typesEvent: [TypeEvent(color: Colors.red, name: "Fêtes (France)")],
    ),

    ReelCalendarEvent(
      id: '4',
      title: 'Jour plus',
      start: DateTime(now.year, now.month, now.day + 1),
      end: DateTime(now.year, now.month, now.day + 2),
      allDay: true,
      description: '',
      typesEvent: [TypeEvent(color: Colors.red, name: "Fêtes (France)")],
    ),

    // ───── EVENTS NON ALL-DAY EXISTANTS ─────
    ReelCalendarEvent(
      id: '3',
      title: 'Call sometime I am sad',
      description: 'petite description ici tres rapide',
      start: DateTime(now.year, now.month, now.day, 17),
      end: DateTime(now.year, now.month, now.day, 18),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.green, name: 'yassine@gmail.com')],
    ),

    ReelCalendarEvent(
      id: '5',
      title: 'Call my mon',
      description: 'petite description ici tres rapide',
      start: DateTime(2026, 1, 5, 10, 30),
      end: DateTime(2026, 1, 5, 10, 35),
      allDay: false,
      typesEvent: [TypeEvent(color: Colors.green, name: 'yassine@gmail.com')],
    ),

    // ───── OCCURRENCES API (LECTURE DU CORAN) ─────
    ...coranEvents,
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

  calendarController.setView(CalendarView.week);

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
