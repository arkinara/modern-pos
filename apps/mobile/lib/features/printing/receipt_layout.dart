/// Pure text layout helpers for fixed-width thermal receipts.
///
/// Widths are expressed in printer columns, not pixels. All helpers are pure so
/// wrapping, truncation and column alignment are unit tested without hardware.
abstract final class ReceiptLayout {
  /// Hard-wraps [text] to at most [width] characters per line.
  ///
  /// Words longer than [width] are split instead of overflowing the paper.
  /// Existing newlines start a new line. A blank/zero width yields no lines.
  static List<String> wrap(String text, int width) {
    if (width <= 0) {
      return const [];
    }
    final lines = <String>[];
    for (final paragraph in text.split('\n')) {
      final words = paragraph.trim().split(RegExp(r'\s+'));
      final current = StringBuffer();
      for (final word in words) {
        if (word.isEmpty) {
          continue;
        }
        var remaining = word;
        while (remaining.length > width) {
          if (current.isNotEmpty) {
            lines.add(current.toString());
            current.clear();
          }
          lines.add(remaining.substring(0, width));
          remaining = remaining.substring(width);
        }
        if (current.isEmpty) {
          current.write(remaining);
        } else if (current.length + 1 + remaining.length <= width) {
          current
            ..write(' ')
            ..write(remaining);
        } else {
          lines.add(current.toString());
          current
            ..clear()
            ..write(remaining);
        }
      }
      if (current.isNotEmpty) {
        lines.add(current.toString());
      }
    }
    return lines;
  }

  /// Places [left] and [right] on one line, right-aligning [right].
  ///
  /// If both do not fit, the row is split into two lines so no amount is cut.
  static List<String> columns(String left, String right, int width) {
    if (width <= 0) {
      return const [];
    }
    final safeRight = right.length > width
        ? right.substring(right.length - width)
        : right;
    final space = width - safeRight.length;
    if (left.length < space) {
      return ['$left${' ' * (space - left.length)}$safeRight'];
    }
    if (left.length <= width) {
      return [left, safeRight.padLeft(width)];
    }
    final wrapped = wrap(left, width);
    return [...wrapped, safeRight.padLeft(width)];
  }

  /// Truncates [text] to [width] characters with a trailing ellipsis marker.
  static String truncate(String text, int width) {
    if (width <= 0) {
      return '';
    }
    if (text.length <= width) {
      return text;
    }
    if (width <= 3) {
      return text.substring(0, width);
    }
    return '${text.substring(0, width - 3)}...';
  }

  static String divider(int width, [String character = '-']) {
    if (width <= 0) {
      return '';
    }
    return character * width;
  }
}
