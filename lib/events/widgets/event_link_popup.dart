import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/utils/inline_icons_helper.dart';

class EventLinkIcon extends StatefulWidget {
  final EventLink link;
  final VoidCallback onTap;

  const EventLinkIcon({super.key, required this.link, required this.onTap});

  @override
  State<EventLinkIcon> createState() => _EventLinkIconState();
}

class _EventLinkIconState extends State<EventLinkIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovered
        ? colorForEventLink(widget.link.type)
        : const Color(0xFF374151); // gris neutre

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: '${widget.link.label} : ${widget.link.value}',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovered
                  ? color.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.string(
              iconForEventLink(widget.link.type),
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
