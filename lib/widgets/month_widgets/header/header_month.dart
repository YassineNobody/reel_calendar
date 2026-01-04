import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final DateTime month;

  const MonthHeader({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final monthName = _monthLabel(month.month);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$monthName ${month.year}',
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(190, 0, 0, 0),
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }

  String _monthLabel(int m) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[m - 1];
  }
}
