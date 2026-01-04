String formatMonthYear(DateTime startOfWeek) {
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  final monthName = months[startOfWeek.month - 1];
  final year = startOfWeek.year;

  return '$monthName $year'.toLowerCase();
}

String formatDay({required DateTime day, bool capitalize = false}) {
  const months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  final monthName = months[day.month - 1];
  final year = day.year;

  return '${day.day} ${capitalize ? monthName : monthName.toLowerCase()} $year';
}

String formatWeekday({required DateTime day, bool capitalize = false}) {
  const weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  // DateTime.weekday : 1 = lundi, 7 = dimanche
  final name = weekdays[day.weekday - 1];
  return capitalize ? name : name.toLowerCase();
}
