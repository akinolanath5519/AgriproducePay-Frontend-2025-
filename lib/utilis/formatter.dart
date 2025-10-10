import 'package:intl/intl.dart';

/// ---------------------
/// Currency symbols
/// ---------------------
class Currency {
  static const naira = '₦';
  static const dollar = '\$';
  // Add more as needed
}

/// ---------------------
/// Number formatting
/// ---------------------
extension NumFormatting on num {
  /// Format number with commas and 2 decimal places
  String toFormatted() => NumberFormat('#,##0.00').format(this);

  /// Format number as currency
  /// Default is Naira (₦)
  String toCurrency({String symbol = Currency.naira}) =>
      NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(this);

  /// Format number as integer with commas
  String toIntFormatted() => NumberFormat('#,###').format(this);
}

/// ---------------------
/// DateTime formatting
/// ---------------------
extension DateFormatting on DateTime {
  /// Format date as `dd/MM/yyyy`
 String toDateFormatted([String? pattern]) {

    return DateFormat(pattern ?? 'dd-MM-yyyy').format(this);
  }
  /// Format date and time as `dd MMM yyyy, hh:mm a`
  String toDateTimeFormatted({String pattern = 'dd MMM yyyy, hh:mm a'}) =>
      DateFormat(pattern).format(this);

  /// Format only time `hh:mm a`
  String toTimeFormatted({String pattern = 'hh:mm a'}) =>
      DateFormat(pattern).format(this);
}
