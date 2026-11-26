import 'package:intl/intl.dart';

import '../../domain/domain.dart';

/// Display helpers so screens don't format numbers and dates themselves.
class Formatters {
  static final _money = NumberFormat('#,##0.00', 'en_US');
  static final _date = DateFormat('MMM d, y', 'en_US');

  /// 2548 → "$ 2,548.00"
  static String money(double value) => '\$ ${_money.format(value.abs())}';

  /// Income → "+ $ 850.00", expense → "- $ 85.00"
  static String signedMoney(Transaction t) =>
      '${t.isIncome ? '+' : '-'} ${money(t.amount)}';

  /// "Өнөөдөр", "Өчигдөр", otherwise "Jan 30, 2022" (as in the design).
  static String relativeDate(DateTime date, {DateTime? now}) {
    final today = _dayOnly(now ?? DateTime.now());
    final diff = today.difference(_dayOnly(date)).inDays;
    if (diff == 0) return 'Өнөөдөр';
    if (diff == 1) return 'Өчигдөр';
    return _date.format(date);
  }

  static final _longDate = DateFormat('EEE, d MMM y', 'en_US');
  static final _time = DateFormat('hh:mm a', 'en_US');

  /// "Tue, 22 Feb 2022" — Add Expense date field.
  static String longDate(DateTime date) => _longDate.format(date);

  /// "08:15 AM" — receipt time.
  static String time(DateTime date) => _time.format(date);

  /// "Feb 28, 2022" — bill due dates.
  static String date(DateTime date) => _date.format(date);

  /// Greeting by time of day.
  static String greeting(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'Өглөөний мэнд';
    if (h >= 12 && h < 18) return 'Өдрийн мэнд';
    return 'Оройн мэнд';
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
