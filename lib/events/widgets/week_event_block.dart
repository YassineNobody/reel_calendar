import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/event_block_compact.dart';
import 'package:reel_calendar/events/widgets/event_block_normal.dart';
import 'package:reel_calendar/events/widgets/event_popover.dart';
import 'package:reel_calendar/events/widgets/event_popover_positionning.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';
import 'package:reel_calendar/utils/week_event_layout.dart';

import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';

class WeekEventBlock extends StatefulWidget {
  final ReelCalendarEvent event;
  final double top;
  final double height;
  final bool isDayView;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  final ReelCalendarEventController controller;

  const WeekEventBlock({
    super.key,
    required this.event,
    required this.top,
    required this.height,
    required this.controller,
    required this.onMenuAction,
    required this.onEventLinkTap,
    this.isDayView = false,
  });

  @override
  State<WeekEventBlock> createState() => _WeekEventBlockState();
}

class _WeekEventBlockState extends State<WeekEventBlock> {
  OverlayEntry? _popoverEntry;

  @override
  void dispose() {
    _hidePopover();
    super.dispose();
  }

  void _showPopover() {
    _hidePopover(); // sécurité

    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;

    // ⚠️ taille estimée du popover
    const popoverSize = Size(320, 220);

    final offset = computePopoverPosition(context, box, popoverSize);

    _popoverEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // clic hors popover → fermeture
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hidePopover,
            ),
          ),

          // popover positionné intelligemment
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: EventPopover(
              event: widget.event,
              onEventLinkTap: widget.onEventLinkTap,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_popoverEntry!);
  }

  void _hidePopover() {
    _popoverEntry?.remove();
    _popoverEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = isMinSize(
      start: widget.event.start,
      end: widget.event.end,
    );

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final bool isSelected = widget.controller.isSelected(widget.event);

        return Positioned(
          top: widget.top,
          left: 1,
          right: 1,
          height: widget.height,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              if ((e.buttons & kSecondaryMouseButton) != 0) {
                final menuContext = CalendarMenuContext(
                  view: widget.isDayView ? CalendarView.day : CalendarView.week,
                  target: CalendarMenuTarget.event,
                  day: DateTime(
                    widget.event.start.year,
                    widget.event.start.month,
                    widget.event.start.day,
                  ),
                  event: widget.event,
                );

                openCalendarContextMenu<String>(
                  context: context,
                  clickPosition: e.position,
                  menuContext: menuContext,
                  onSelected: (value) {
                    widget.onMenuAction?.call(value, menuContext);
                  },
                );
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,

              // ───── CLIC GAUCHE ─────
              onTapDown: (_) {
                widget.controller.selectEvent(widget.event);
                _hidePopover();
              },

              // ───── DOUBLE CLIC ─────
              onDoubleTap: widget.isDayView
                  ? null
                  : () {
                      if (isSelected) {
                        _showPopover();
                      }
                    },

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.event.typesEvent.first.color
                      : widget.event.typesEvent.first.color.withValues(
                          alpha: 0.3,
                        ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border(
                    left: BorderSide(
                      color: widget.event.typesEvent.first.color,
                      width: isSelected ? 5 : 3.5,
                    ),
                  ),
                ),
                child: compact
                    ? buildEventBlockCompact(widget.event, isSelected)
                    : buildEventBlockNormal(widget.event, isSelected),
              ),
            ),
          ),
        );
      },
    );
  }
}
