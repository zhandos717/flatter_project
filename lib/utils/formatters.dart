import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(amount) {
    return NumberFormat.currency(
      symbol: '\₸ ',
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatCompact(double amount) {
    return NumberFormat.compactCurrency(
      symbol: '\₸',
      decimalDigits: 0,
    ).format(amount);
  }
}

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat.MMMM().format(date);
  }
}
