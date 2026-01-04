import 'package:flutter/material.dart';

class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: labels
            .map(
              (l) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Text(
                    l,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 16.5,
                      color: Color.fromARGB(214, 0, 0, 0),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
