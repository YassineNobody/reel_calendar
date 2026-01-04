const weekDaysFr = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

const monthsFr = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];
String _twoDigits(int n) => n.toString().padLeft(2, '0');

String formatHour(DateTime d) =>
    '${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';
