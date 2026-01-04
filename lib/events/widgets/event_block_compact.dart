import 'package:flutter/material.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';

Widget buildEventBlockCompact(ReelCalendarEvent event, bool isSelected) {
  return Align(
    alignment: Alignment.topLeft,
    child: Text(
      event.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      strutStyle: const StrutStyle(
        fontSize: 12,
        height: 1.0,
        forceStrutHeight: true,
      ),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : event.typesEvent.first.color,
      ),
    ),
  );
}
