import 'dart:convert';
import 'dart:typed_data';

import 'printer_models.dart';

/// Encodes receipt text into the single-byte stream sent to the printer.
///
/// CP437 is implemented in pure Dart so it can be unit tested without hardware.
/// Characters outside the code page become `?` instead of silently changing the
/// receipt. The printer's active code page still has to match this selection on
/// real hardware (`PENDING — requires printer model`).
abstract final class PrinterTextEncoder {
  static Uint8List encode(String text, PrinterEncoding encoding) {
    return switch (encoding) {
      PrinterEncoding.cp437 => Cp437Encoder.encode(text),
      PrinterEncoding.utf8 => Uint8List.fromList(utf8.encode(text)),
    };
  }
}

/// Minimal CP437 encoder covering printable ASCII and the IBM upper half.
abstract final class Cp437Encoder {
  static const _unsupported = 0x3F; // '?'

  /// CP437 bytes `0x80..0xFF`, in order.
  static const _upper =
      'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒáíóúñÑªº¿⌐¬½¼¡«»'
      '░▒▓│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀'
      'αßΓπΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈°∙·√ⁿ²■\u00A0';

  static final Map<int, int> _table = _buildTable();

  static Map<int, int> _buildTable() {
    final table = <int, int>{};
    for (var codeUnit = 0x20; codeUnit <= 0x7E; codeUnit++) {
      table[codeUnit] = codeUnit;
    }
    for (var index = 0; index < _upper.length; index++) {
      table[_upper.codeUnitAt(index)] = 0x80 + index;
    }
    return table;
  }

  static Uint8List encode(String text) {
    final bytes = Uint8List(text.length);
    for (var index = 0; index < text.length; index++) {
      bytes[index] = _table[text.codeUnitAt(index)] ?? _unsupported;
    }
    return bytes;
  }

  /// Number of bytes produced per character; one for every CP437 code point.
  static int get supportedCharacterCount => _table.length;
}
