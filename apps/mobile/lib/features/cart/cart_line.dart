import '../../core/formatting/money.dart';

/// One unsent cart line. The line keeps the price observed when it was added;
/// the server remains authoritative for the final quote in #12.
class CartLine {
  const CartLine({
    required this.menuId,
    required this.variantId,
    required this.itemName,
    required this.variantName,
    required this.unitPriceMinor,
    required this.quantity,
    required this.currency,
    required this.currencyExponent,
  });

  static const maxQuantity = 999;

  final String menuId;
  final String variantId;
  final String itemName;
  final String variantName;
  final int unitPriceMinor;
  final int quantity;
  final String currency;
  final int currencyExponent;

  int get subtotalMinor => unitPriceMinor * quantity;

  MoneyFormat get money =>
      MoneyFormat(currency: currency, currencyExponent: currencyExponent);

  CartLine copyWith({int? quantity}) {
    return CartLine(
      menuId: menuId,
      variantId: variantId,
      itemName: itemName,
      variantName: variantName,
      unitPriceMinor: unitPriceMinor,
      quantity: quantity ?? this.quantity,
      currency: currency,
      currencyExponent: currencyExponent,
    );
  }

  String get key => '$menuId::$variantId';
}
