/// Currency formatting for integer minor units.
///
/// All money is carried as integer minor units. Never convert through double:
/// IDR uses exponent 0 (`Rp28.000`) and other demo currencies use their
/// contract exponent. Display-only totals remain advisory until the server
/// quote is introduced in #12.
class MoneyFormat {
  const MoneyFormat({required this.currency, required this.currencyExponent})
    : assert(currencyExponent >= 0 && currencyExponent <= 3);

  final String currency;
  final int currencyExponent;

  static const idr = MoneyFormat(currency: 'IDR', currencyExponent: 0);

  String format(int minorUnits) {
    final negative = minorUnits < 0;
    final absolute = minorUnits.abs();
    final divisor = _pow10(currencyExponent);
    final whole = absolute ~/ divisor;
    final fraction = absolute % divisor;

    final wholeText = _groupDigits(whole.toString());
    final fractionText = currencyExponent == 0
        ? ''
        : '.${fraction.toString().padLeft(currencyExponent, '0')}';

    final prefix = currency == 'IDR' ? 'Rp' : '$currency ';
    return '${negative ? '-' : ''}$prefix$wholeText$fractionText';
  }

  static int _pow10(int exponent) {
    var value = 1;
    for (var index = 0; index < exponent; index++) {
      value *= 10;
    }
    return value;
  }

  static String _groupDigits(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }
}
