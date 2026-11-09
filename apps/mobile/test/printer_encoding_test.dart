import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/printer_encoding.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

void main() {
  group('Cp437Encoder', () {
    test('maps printable ASCII to the same byte value', () {
      expect(Cp437Encoder.encode('ABC xyz 019'), [
        0x41,
        0x42,
        0x43,
        0x20,
        0x78,
        0x79,
        0x7A,
        0x20,
        0x30,
        0x31,
        0x39,
      ]);
    });

    test('maps IBM upper-half characters to CP437 bytes', () {
      final bytes = Cp437Encoder.encode('Çüéâ');
      expect(bytes, [0x80, 0x81, 0x82, 0x83]);
      expect(Cp437Encoder.encode('£¥'), [0x9C, 0x9D]);
    });

    test('replaces characters outside the code page with question mark', () {
      expect(Cp437Encoder.encode('€'), [0x3F]);
      expect(Cp437Encoder.encode('A€B'), [0x41, 0x3F, 0x42]);
    });

    test('exposes the full printable ASCII plus upper-half table', () {
      expect(Cp437Encoder.supportedCharacterCount, 95 + 128);
    });
  });

  group('PrinterTextEncoder', () {
    test('UTF-8 keeps multi-byte characters distinct from CP437', () {
      final utf8Bytes = PrinterTextEncoder.encode('é', PrinterEncoding.utf8);
      expect(utf8Bytes, utf8.encode('é'));
      expect(utf8Bytes.length, 2);

      final cp437Bytes = PrinterTextEncoder.encode('é', PrinterEncoding.cp437);
      expect(cp437Bytes, [0x82]);
      expect(cp437Bytes.length, 1);
    });
  });
}
