/// Форматирование дат на русском без подгрузки данных локали intl.
abstract final class DateFormatter {
  static const _months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];

  /// «5 мая» — день и месяц.
  static String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// «5 мая 2026» — с годом.
  static String full(DateTime d) => '${dayMonth(d)} ${d.year}';
}
