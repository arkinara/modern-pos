import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/formatting/money.dart';

void main() {
  group('MoneyFormat', () {
    test('IDR exponent 0 formats integer minor units without floats', () {
      const idr = MoneyFormat(currency: 'IDR', currencyExponent: 0);
      expect(idr.format(28000), 'Rp28.000');
      expect(idr.format(0), 'Rp0');
      expect(idr.format(1234567), 'Rp1.234.567');
      expect(idr.format(999), 'Rp999');
    });

    test('non-zero exponent keeps exact minor-unit fraction', () {
      const usd = MoneyFormat(currency: 'USD', currencyExponent: 2);
      expect(usd.format(1250), 'USD 12.50');
      expect(usd.format(5), 'USD 0.05');
      expect(usd.format(100000), 'USD 1.000.00');
    });

    test('subtotal arithmetic stays in integer minor units', () {
      const price = 28000;
      const quantity = 3;
      expect(price * quantity, 84000);
      const idr = MoneyFormat(currency: 'IDR', currencyExponent: 0);
      expect(idr.format(price * quantity), 'Rp84.000');
    });
  });
}
