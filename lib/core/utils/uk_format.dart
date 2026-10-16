/// Допоміжні функції для українських дат і відмінків числівників.
abstract final class UkFormat {
  static const List<String> _weekdays = [
    'Понеділок',
    'Вівторок',
    'Середа',
    'Четвер',
    'Пʼятниця',
    'Субота',
    'Неділя',
  ];

  static const List<String> _monthsGenitive = [
    'січня',
    'лютого',
    'березня',
    'квітня',
    'травня',
    'червня',
    'липня',
    'серпня',
    'вересня',
    'жовтня',
    'листопада',
    'грудня',
  ];

  /// наприклад: «Понеділок, 28 вересня»
  static String weekdayDayMonth(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} ${_monthsGenitive[date.month - 1]}';

  /// обирає форму слова (1 робота/5 робіт і тд)
  static String plural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }
}