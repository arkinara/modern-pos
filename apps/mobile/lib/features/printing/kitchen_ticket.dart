import 'esc_pos_receipt.dart';
import 'receipt_layout.dart';

/// A kitchen ticket is derived from one server station job. The server decides
/// routing and keeps the stable order reference; the device only renders it.
enum KitchenTicketKind {
  original('ORIGINAL', 'ORIGINAL'),
  amend('AMEND', 'AMENDMENT'),
  cancel('CANCEL', 'CANCELLATION');

  const KitchenTicketKind(this.wireName, this.title);

  final String wireName;
  final String title;

  static KitchenTicketKind fromWire(String? value) {
    return KitchenTicketKind.values.firstWhere(
      (kind) => kind.wireName == value,
      orElse: () => KitchenTicketKind.original,
    );
  }
}

class KitchenTicketModifier {
  const KitchenTicketModifier({required this.name, this.quantity = 1});

  final String name;
  final int quantity;

  String get label => quantity > 1 ? '$name x$quantity' : name;

  static List<KitchenTicketModifier> fromJsonList(List<Object?> value) {
    final modifiers = <KitchenTicketModifier>[];
    for (final entry in value) {
      if (entry is Map) {
        final name = entry['name'];
        if (name is String && name.isNotEmpty) {
          final quantity = entry['quantity'];
          modifiers.add(
            KitchenTicketModifier(
              name: name,
              quantity: quantity is int && quantity > 0 ? quantity : 1,
            ),
          );
        }
      }
    }
    return modifiers;
  }
}

/// Immutable ticket content copied from the station job snapshot.
class KitchenTicket {
  const KitchenTicket({
    required this.jobId,
    required this.stationName,
    required this.orderReference,
    required this.kind,
    required this.itemName,
    required this.variantName,
    required this.quantity,
    required this.modifiers,
    this.copy = false,
    this.reprintOfId,
    this.issuedAtLabel,
  });

  final String jobId;
  final String stationName;
  final String orderReference;
  final KitchenTicketKind kind;
  final String itemName;
  final String variantName;
  final int quantity;
  final List<KitchenTicketModifier> modifiers;
  final bool copy;
  final String? reprintOfId;
  final String? issuedAtLabel;

  bool get isCancellation => kind == KitchenTicketKind.cancel;
}

/// Pure visible content for a kitchen ticket. Bytes are added only around these
/// lines, so the exact paper text is testable without hardware.
abstract final class KitchenTicketDocument {
  static List<ReceiptDocumentLine> build(KitchenTicket ticket, int columns) {
    if (columns <= 0) {
      return const [];
    }
    final lines = <ReceiptDocumentLine>[];

    for (final line in ReceiptLayout.wrap(ticket.stationName, columns)) {
      lines.add(_center(line, bold: true));
    }
    for (final line in ReceiptLayout.wrap(ticket.kind.title, columns)) {
      lines.add(_center(line, bold: true));
    }
    if (ticket.copy) {
      for (final line in ReceiptLayout.wrap(
        'COPY - NOT AN ORIGINAL',
        columns,
      )) {
        lines.add(_center(line, bold: true));
      }
    }
    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));

    for (final line in ReceiptLayout.wrap(
      'Order: ${ticket.orderReference}',
      columns,
    )) {
      lines.add(ReceiptDocumentLine(line));
    }
    if (ticket.issuedAtLabel != null && ticket.issuedAtLabel!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(ticket.issuedAtLabel!, columns)) {
        lines.add(ReceiptDocumentLine(line));
      }
    }
    if (ticket.reprintOfId != null && ticket.reprintOfId!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(
        'Copy of job: ${ticket.reprintOfId}',
        columns,
      )) {
        lines.add(ReceiptDocumentLine(line));
      }
    }
    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));

    for (final line in ReceiptLayout.wrap(
      '${ticket.quantity} x ${ticket.itemName}',
      columns,
    )) {
      lines.add(ReceiptDocumentLine(line, bold: true));
    }
    if (ticket.variantName.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(ticket.variantName, columns)) {
        lines.add(ReceiptDocumentLine(line));
      }
    }
    for (final modifier in ticket.modifiers) {
      for (final line in ReceiptLayout.wrap('+ ${modifier.label}', columns)) {
        lines.add(ReceiptDocumentLine(line));
      }
    }

    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));
    for (final line in ReceiptLayout.wrap(
      ticket.isCancellation ? 'ITEM CANCELLED' : ticket.kind.title,
      columns,
    )) {
      lines.add(_center(line));
    }
    return lines;
  }

  static ReceiptDocumentLine _center(String text, {bool bold = false}) {
    return ReceiptDocumentLine(
      text,
      alignment: ReceiptLineAlignment.center,
      bold: bold,
    );
  }
}
