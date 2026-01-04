import 'package:flutter/material.dart';
import 'package:reel_calendar/enums/event_link.dart';

class TypeEvent {
  final Color color;
  final String name;
  const TypeEvent({required this.color, required this.name});
}

class EventLink {
  final EventLinkType type;
  final String value; // url, numéro, email, etc.
  final String label; // optionnel (ex: "Réunion Zoom")
  const EventLink({
    required this.type,
    required this.value,
    required this.label,
  });
}

extension EventLinkX on EventLink {
  bool get isExternal =>
      type == EventLinkType.url ||
      type == EventLinkType.zoom ||
      type == EventLinkType.telegram ||
      type == EventLinkType.whatsapp;
}

class ReelCalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final String description;
  final DateTime end;
  final bool allDay;
  final List<TypeEvent> typesEvent;
  final EventLink? eventLink;

  const ReelCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.typesEvent,
    this.eventLink,
    this.allDay = false,
  });

  bool occursOnDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    if (allDay) {
      // end EXCLUSIF
      return !d.isBefore(startDay) && d.isBefore(endDay);
    }

    return start.isBefore(d.add(const Duration(days: 1))) && end.isAfter(d);
  }
}
