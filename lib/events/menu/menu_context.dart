import 'package:flutter/material.dart';
import 'package:reel_calendar/enums/calendar_menu_target.dart';
import 'package:reel_calendar/enums/calendar_view.dart';
import 'package:reel_calendar/events/model/menu_item_calendar_left.dart';

/// ─────────────────────────────────────────────
/// CONTEXTE DU MENU
/// ─────────────────────────────────────────────
class CalendarMenuContext {
  final CalendarView view;
  final CalendarMenuTarget target;
  final DateTime day;
  final dynamic
  event; // ReelCalendarEvent? (dynamic pour éviter dépendance circulaire)

  const CalendarMenuContext({
    required this.view,
    required this.target,
    required this.day,
    this.event,
  });
}

/// ─────────────────────────────────────────────
/// MENU CONTEXTUEL
/// ─────────────────────────────────────────────
class CalendarContextMenu<T> extends StatelessWidget {
  final CalendarMenuContext contextData;
  final void Function(T value) onSelected;

  const CalendarContextMenu({
    super.key,
    required this.contextData,
    required this.onSelected,
  });

  /// ───────── ITEMS SELON CONTEXTE ─────────
  List<CalendarMenuItem<T>> _buildItems() {
    switch (contextData.target) {
      case CalendarMenuTarget.event:
        return [
          CalendarMenuItem(value: 'edit' as T, label: 'Modifier'),
          CalendarMenuItem(
            value: 'delete' as T,
            label: 'Supprimer',
            danger: true,
          ),
        ];

      case CalendarMenuTarget.dayWithEvents:
        final items = <CalendarMenuItem<T>>[];

        // 👇 uniquement si on N’EST PAS déjà en DayView
        if (contextData.view != CalendarView.day) {
          items.add(
            CalendarMenuItem(
              value: 'openDay' as T,
              label: 'Voir les événements',
            ),
          );
        }

        items.add(
          CalendarMenuItem(value: 'add' as T, label: 'Ajouter un événement'),
        );

        return items;

      case CalendarMenuTarget.dayEmpty:
        return [
          CalendarMenuItem(value: 'add' as T, label: 'Ajouter un événement'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return _MenuItem(item: item, onTap: () => onSelected(item.value));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// ITEM DU MENU
/// ─────────────────────────────────────────────
class _MenuItem<T> extends StatefulWidget {
  final CalendarMenuItem<T> item;
  final VoidCallback onTap;

  const _MenuItem({required this.item, required this.onTap});

  @override
  State<_MenuItem<T>> createState() => _MenuItemState<T>();
}

class _MenuItemState<T> extends State<_MenuItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _hovered
                ? const Color.fromARGB(255, 46, 163, 25) // hover réaliste
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 12,
                  color: _hovered ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
