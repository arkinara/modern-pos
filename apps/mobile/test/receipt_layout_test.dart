import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/receipt_layout.dart';

void main() {
  group('ReceiptLayout.wrap', () {
    test('wraps words at the column boundary', () {
      expect(ReceiptLayout.wrap('ABC DEF GHI', 7), ['ABC DEF', 'GHI']);
      expect(ReceiptLayout.wrap('one two three four', 9), [
        'one two',
        'three',
        'four',
      ]);
    });

    test('hard-splits a word longer than the width without overflow', () {
      expect(ReceiptLayout.wrap('ABCDEFGHIJ', 4), ['ABCD', 'EFGH', 'IJ']);
    });

    test('keeps every line within the available columns', () {
      const text = 'Iced latte with extra oat milk and a long note';
      for (final line in ReceiptLayout.wrap(text, 16)) {
        expect(line.length, lessThanOrEqualTo(16));
      }
    });

    test('returns no lines for a non-positive width', () {
      expect(ReceiptLayout.wrap('anything', 0), isEmpty);
    });
  });

  group('ReceiptLayout.columns', () {
    test('right-aligns the amount on a single line of exact width', () {
      final lines = ReceiptLayout.columns('Total', 'Rp10.000', 16);
      expect(lines, hasLength(1));
      expect(lines.single.length, 16);
      expect(lines.single, startsWith('Total'));
      expect(lines.single, endsWith('Rp10.000'));
    });

    test('splits instead of truncating when the label is too long', () {
      final lines = ReceiptLayout.columns(
        'Very long item name that will not fit',
        'Rp1.000',
        12,
      );
      expect(lines.length, greaterThan(1));
      expect(lines.last.length, 12);
      expect(lines.last.trim(), 'Rp1.000');
    });
  });

  group('ReceiptLayout.truncate and divider', () {
    test('adds an ellipsis marker at the requested width', () {
      expect(ReceiptLayout.truncate('ABCDEFGHIJKLM', 10), 'ABCDEFG...');
      expect(ReceiptLayout.truncate('short', 10), 'short');
    });

    test('builds a divider of the printer width', () {
      expect(ReceiptLayout.divider(8), '--------');
    });
  });
}
