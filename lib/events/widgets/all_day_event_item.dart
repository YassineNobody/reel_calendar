import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reel_calendar/controllers/event_controller.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/event_popover.dart';
import 'package:reel_calendar/events/widgets/event_popover_positionning.dart';
import 'package:reel_calendar/utils/calendar_context_menu_helper.dart';

class AllDayEventItem extends StatefulWidget {
  final ReelCalendarEvent event;
  final ReelCalendarEventController controller;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool isDayView;
  final void Function(String action, CalendarMenuContext context)? onMenuAction;
  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;

  const AllDayEventItem({
    super.key,
    required this.event,
    required this.controller,
    required this.height,
    required this.padding,
    required this.margin,
    required this.onMenuAction,
    required this.onEventLinkTap,
    this.isDayView = false,
  });

  @override
  State<AllDayEventItem> createState() => _AllDayEventItemState();
}

class _AllDayEventItemState extends State<AllDayEventItem> {
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
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final isSelected = widget.controller.isSelected(widget.event);

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            // ───── CLIC DROIT → MENU EVENT ─────
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
                    final isSelected = widget.controller.isSelected(
                      widget.event,
                    );
                    if (isSelected) {
                      _showPopover();
                    }
                  },

            child: Container(
              height: widget.height,
              margin: widget.margin,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.event.typesEvent.first.color
                    : widget.event.typesEvent.first.color.withValues(
                        alpha: 0.35,
                      ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : widget.event.typesEvent.first.color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
