import 'package:flutter/material.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';

Widget buildEventBlockNormal(ReelCalendarEvent event, bool isSelected) {
  final minutes = event.end.difference(event.start).inMinutes;
  if (minutes <= 30) {
    return _buildEventBlockMedium(event, isSelected);
  } else {
    return _buildEventBlockLarge(event, isSelected);
  }
}

Widget _buildEventBlockLarge(ReelCalendarEvent event, bool isSelected) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(height: 2),
      _buildHours(event, isSelected),
      SizedBox(height: 2),
      _buildTitle(event, isSelected),
    ],
  );
}

Widget _buildEventBlockMedium(ReelCalendarEvent event, bool isSelected) {
  return Align(
    alignment: AlignmentGeometry.centerLeft,
    child: Row(children: [_buildTitle(event, isSelected)]),
  );
}

Widget _buildHours(ReelCalendarEvent event, bool isSelected) {
  final h = event.start.hour.toString().padLeft(2, '0');
  final m = event.start.minute.toString().padLeft(2, '0');

  return Text(
    '$h:$m',
    maxLines: 1,
    strutStyle: const StrutStyle(
      fontSize: 11,
      height: 1.0,
      forceStrutHeight: true,
    ),
    style: TextStyle(
      fontSize: 11, // 👈 légèrement plus petit que le titre
      color: isSelected
          ? Colors.white
          : event.typesEvent.first.color.withValues(alpha: 0.9),
    ),
  );
}

Widget _buildTitle(ReelCalendarEvent event, bool isSelected) {
  return Flexible(
    fit: FlexFit.loose,
    child: Text(
      event.title,
      strutStyle: const StrutStyle(
        fontSize: 12,
        height: 1.0,
        forceStrutHeight: true,
      ),
      softWrap: true, // 👈 retour à la ligne naturel
      overflow: TextOverflow.ellipsis, // 👈 seulement si plus de place
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : event.typesEvent.first.color,
      ),
    ),
  );
}
