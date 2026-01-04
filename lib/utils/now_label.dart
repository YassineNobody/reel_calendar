import 'package:flutter/widgets.dart';

Widget buildNowTimeLabel(
  bool isCurrentWeek,
  double hourHeight,
  double hourColumnWidth,
) {
  if (!isCurrentWeek) return const SizedBox.shrink();

  final now = DateTime.now();
  final minutes = now.hour * 60 + now.minute;
  final y = (minutes / 60) * hourHeight;

  final label =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  return SizedBox(
    height: hourHeight * 24,
    width: hourColumnWidth,
    child: Stack(
      children: [
        Positioned(
          top: y - 7,
          right: 6,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
