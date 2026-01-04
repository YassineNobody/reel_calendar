import 'package:flutter/material.dart';
import 'package:reel_calendar/events/menu/menu_context.dart';

void openCalendarContextMenu<T>({
  required BuildContext context,
  required CalendarMenuContext menuContext,
  required Offset clickPosition,
  required void Function(T value) onSelected,
}) {
  const double menuWidth = 220;
  const double menuEstimatedHeight = 180;
  const double padding = 8;

  final Size screenSize = MediaQuery.of(context).size;

  double left = clickPosition.dx;
  double top = clickPosition.dy;

  // ───── HORIZONTAL ─────
  if (left + menuWidth + padding > screenSize.width) {
    left = screenSize.width - menuWidth - padding;
  }
  if (left < padding) left = padding;

  // ───── VERTICAL ─────
  if (top + menuEstimatedHeight + padding > screenSize.height) {
    top = screenSize.height - menuEstimatedHeight - padding;
  }
  if (top < padding) top = padding;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'CalendarContextMenu',
    barrierColor: Colors.transparent,
    pageBuilder: (_, __, ___) {
      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: CalendarContextMenu<T>(
              contextData: menuContext,
              onSelected: (value) {
                Navigator.pop(context);
                onSelected(value);
              },
            ),
          ),
        ],
      );
    },
  );
}
