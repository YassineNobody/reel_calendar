import 'package:flutter/material.dart';
import 'package:reel_calendar/constants/local_fr.dart';
import 'package:reel_calendar/events/model/reel_calendar_event.dart';
import 'package:reel_calendar/events/widgets/event_link_popup.dart';
import 'package:reel_calendar/widgets/select/custom_select.dart';

class EventPanelContent extends StatefulWidget {
  final ReelCalendarEvent event;

  final void Function(ReelCalendarEvent event, EventLink link)? onEventLinkTap;
  const EventPanelContent({
    super.key,
    required this.event,
    required this.onEventLinkTap,
  });

  @override
  State<EventPanelContent> createState() => _EventPanelContentState();
}

class _EventPanelContentState extends State<EventPanelContent> {
  late TypeEvent _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.event.typesEvent.first;
  }

  @override
  void didUpdateWidget(covariant EventPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id) {
      _selectedType = widget.event.typesEvent.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🟦 HEADER RESPONSIVE
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 260;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 8),
                    CustomSelect<TypeEvent>(
                      value: _selectedType,
                      items: event.typesEvent,
                      onChanged: (value) {
                        setState(() => _selectedType = value);
                      },
                      itemBuilder: _buildTypeItem,
                    ),
                  ],
                );
              }

              // 🔵 ASSEZ DE PLACE → SPACE BETWEEN
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildTitle()),
                  const SizedBox(width: 12),
                  CustomSelect<TypeEvent>(
                    value: _selectedType,
                    items: event.typesEvent,
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                    },
                    itemBuilder: _buildTypeItem,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 2),
          const Divider(),
          if (event.eventLink != null) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                EventLinkIcon(
                  link: widget.event.eventLink!,
                  onTap: () {
                    widget.onEventLinkTap?.call(event, event.eventLink!);
                  },
                ),
                Text(
                  event.eventLink!.label,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          _buildFormatDate(),

          const SizedBox(height: 15),
          if (event.description.isNotEmpty)
            _buildDescription()
          else
            _buildNoDescription(),
        ],
      ),
    );
  }

  Widget _buildTypeItem(TypeEvent type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: type.color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.black26, width: 0.4),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            type.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.event.title,
      softWrap: true,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildFormatDate() {
    final event = widget.event;

    final start = event.start;
    final end = event.end;

    final weekday = weekDaysFr[start.weekday - 1];
    final day = start.day;
    final month = monthsFr[start.month - 1];

    final startHour = formatHour(start);
    final endHour = formatHour(end);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$weekday $day $month',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        event.allDay
            ? Text(
                '(toute la journée)',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Text(
                'de $startHour à $endHour',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ],
    );
  }

  Widget _buildDescription() {
    final event = widget.event;
    return Text(
      event.description,
      textAlign: TextAlign.start,
      maxLines: 6,
      strutStyle: const StrutStyle(
        fontSize: 11.5,
        height: 1.5,
        forceStrutHeight: true,
      ),
      softWrap: true, // 👈 retour à la ligne naturel
      overflow: TextOverflow.ellipsis, // 👈 seulement si plus de place
      style: const TextStyle(
        fontSize: 11.5,
        color: Colors.black45,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildNoDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Aucune description",
          style: const TextStyle(
            fontSize: 11.5,
            color: Colors.black45,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
