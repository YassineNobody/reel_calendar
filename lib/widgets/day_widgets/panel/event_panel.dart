import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/widgets/day_widgets/panel/event_panel_content.dart';

class SelectedEventPanel extends StatelessWidget {
  final ReelCalendarEventController controller;

  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;
  const SelectedEventPanel({
    super.key,
    required this.controller,
    required this.onEventLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final event = controller.selectedEvent;

        if (event == null) {
          return Container(
            margin: const EdgeInsets.only(top: 4),
            child: SizedBox.expand(
              child: Center(
                child: Text(
                  "Aucun évènement sélectionné",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          );
        }

        return EventPanelContent(event: event, onEventLinkTap: onEventLinkTap);
      },
    );
  }
}
