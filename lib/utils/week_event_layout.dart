double hourToOffset({required DateTime time, required double hourHeight}) {
  return (time.hour + time.minute / 60) * hourHeight;
}

double eventHeight({
  required DateTime start,
  required DateTime end,
  required double hourHeight,
}) {
  final realSeconds = safeDurationSeconds(start, end);

  const int minDisplaySeconds = 15 * 60;

  final displaySeconds = realSeconds < minDisplaySeconds
      ? minDisplaySeconds
      : realSeconds;

  return (displaySeconds / 3600) * hourHeight;
}

bool isMinSize({required DateTime start, required DateTime end}) {
  final realSeconds = end.difference(start).inSeconds;

  const int minDisplaySeconds = 15 * 60;
  return realSeconds <= minDisplaySeconds;
}

int safeDurationSeconds(DateTime start, DateTime end) {
  final seconds = end.difference(start).inSeconds;
  return seconds <= 0 ? 0 : seconds;
}
