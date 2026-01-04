import 'package:flutter/widgets.dart';

class CalendarMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool danger;

  const CalendarMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.danger = false,
  });
}
