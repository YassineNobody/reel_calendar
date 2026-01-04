import 'package:flutter/material.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/event_link_popup.dart';

class EventPopover extends StatelessWidget {
  final ReelCalendarEvent event;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const EventPopover({
    super.key,
    required this.event,
    required this.onEventLinkTap,
  });

  String _formatDate(DateTime d) {
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isAllDay = event.allDay;
    debugPrint('eventLink = ${event.eventLink}');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 245, 245),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 10),
              color: Color.fromARGB(60, 0, 0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────── HEADER ─────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: event.typesEvent.first.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 2, // 👈 OBLIGATOIRE
                    overflow: TextOverflow.ellipsis, // 👈 CORRECT
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ───────── LINK ─────────
                if (event.eventLink != null) ...[
                  SizedBox(width: 4),
                  EventLinkIcon(
                    link: event.eventLink!,
                    onTap: () {
                      onEventLinkTap?.call(event, event.eventLink!);
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 10),
            // ───────── DATE ─────────
            Text(
              _formatDate(event.start),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            // ───────── TIME / ALL DAY ─────────
            Row(
              children: [
                Icon(
                  isAllDay ? Icons.calendar_today : Icons.schedule,
                  size: 14,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  isAllDay
                      ? 'Toute la journée'
                      : '${_formatTime(event.start)} → ${_formatTime(event.end)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),

            // ───────── DESCRIPTION ─────────
            if (event.description.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              Text(
                event.description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
