import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/event_link_popup.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';
import 'package:reel_calendar/utils/format_month.dart';

class DayEventsModal extends StatelessWidget {
  final DateTime day;
  final ReelCalendarEventController eventController;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const DayEventsModal({
    super.key,
    required this.day,
    required this.eventController,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });
  @override
  Widget build(BuildContext context) {
    final Map<String, ReelCalendarEvent> unique = {};

    for (final e in eventController.allDayEventsForDay(day)) {
      unique[e.id] = e;
    }
    for (final e in eventController.timedEventsForDay(day)) {
      unique[e.id] = e;
    }

    final events = unique.values.toList();

    final allDayEvents = events.where((e) => e.allDay).toList();
    final timedEvents = events.where((e) => !e.allDay).toList();
    return Material(
      color: const Color(0xFFF7F7F7),
      child: SafeArea(
        child: Column(
          children: [
            // ───── HEADER FIXE ─────
            _Header(
              title:
                  '${formatWeekday(day: day, capitalize: true)} ${formatDay(day: day, capitalize: false)}',
              onClose: () => Navigator.pop(context),
            ),

            // ───── CONTENT SCROLLABLE ─────
            Expanded(
              child: Container(
                color: const Color.fromARGB(
                  255,
                  249,
                  248,
                  248,
                ), // ou Colors.white
                child: allDayEvents.isEmpty && timedEvents.isEmpty
                    ? const _EmptyState()
                    : CustomScrollView(
                        slivers: [
                          if (allDayEvents.isNotEmpty) ...[
                            _SectionTitle(title: 'Toute la journée'),
                            _EventsSliver(
                              events: allDayEvents,
                              onMenuAction: onMenuAction,
                              onEventLinkTap: onEventLinkTap,
                            ),
                          ],
                          if (timedEvents.isNotEmpty) ...[
                            _SectionTitle(title: 'Événements'),
                            _EventsSliver(
                              events: timedEvents,
                              onMenuAction: onMenuAction,
                              onEventLinkTap: onEventLinkTap,
                            ),
                          ],
                          const SliverPadding(
                            padding: EdgeInsets.only(bottom: 24),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _Header({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ───── CLOSE (LEFT) ─────
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              mouseCursor: SystemMouseCursors.basic,
              icon: const Icon(Icons.close, size: 24),
              onPressed: onClose,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ),

          // ───── TITLE (TRUE CENTER) ─────
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _EventsSliver extends StatelessWidget {
  final List<ReelCalendarEvent> events;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const _EventsSliver({
    required this.events,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _EventCard(
            event: events[index],
            onMenuAction: onMenuAction,
            onEventLinkTap: onEventLinkTap,
          );
        }, childCount: events.length),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final ReelCalendarEvent event;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const _EventCard({
    required this.event,
    required this.onMenuAction,
    required this.onEventLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0.5,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            if ((e.buttons & kSecondaryMouseButton) != 0) {
              final menuContext = CalendarMenuContext(
                view: CalendarView.day,
                target: CalendarMenuTarget.event,
                day: DateTime(
                  event.start.year,
                  event.start.month,
                  event.start.day,
                ),
                event: event,
              );

              openCalendarContextMenu<String>(
                context: context,
                clickPosition: e.position,
                menuContext: menuContext,
                onSelected: (value) {
                  onMenuAction?.call(value, menuContext);
                },
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ───── BARRE COULEUR ─────
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: event.typesEvent.first.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ───── CONTENU ─────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (event.eventLink != null) ...[
                          const SizedBox(height: 4),
                          EventLinkIcon(
                            link: event.eventLink!,
                            onTap: () {
                              onEventLinkTap?.call(event, event.eventLink!);
                            },
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          event.allDay
                              ? 'Toute la journée'
                              : _formatTimeEvent(event),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatTimeEvent(ReelCalendarEvent e) =>
      '${_formatTime(e.start)} → ${_formatTime(e.end)}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Aucun événement pour cette journée',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}
