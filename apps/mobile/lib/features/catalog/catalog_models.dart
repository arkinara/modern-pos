import 'package:modern_pos_api_client/api.dart';

import '../../core/formatting/money.dart';

/// Immutable catalog read model for the cashier screen.
class CatalogSnapshot {
  const CatalogSnapshot({
    required this.categories,
    required this.menus,
    required this.currency,
    required this.currencyExponent,
  });

  final List<Category> categories;
  final List<Menu> menus;
  final String currency;
  final int currencyExponent;

  MoneyFormat get money =>
      MoneyFormat(currency: currency, currencyExponent: currencyExponent);

  Menu? menuById(String menuId) {
    for (final menu in menus) {
      if (menu.id == menuId) {
        return menu;
      }
    }
    return null;
  }

  Variant? variantById(String menuId, String variantId) {
    final menu = menuById(menuId);
    if (menu == null) {
      return null;
    }
    for (final variant in menu.variants) {
      if (variant.id == variantId) {
        return variant;
      }
    }
    return null;
  }
}

/// A variant is selectable when it is enabled and not advisably out of stock.
/// `availableUnits == null` means UNTRACKED and therefore available.
bool variantIsSelectable(Variant variant) {
  if (!variant.enabled) {
    return false;
  }
  final units = variant.availableUnits;
  return units == null || units > 0;
}

String? variantUnavailableReason(Variant variant) {
  if (!variant.enabled) {
    return 'Unavailable';
  }
  final units = variant.availableUnits;
  if (units != null && units <= 0) {
    return 'Out of stock';
  }
  return null;
}

/// Menu-level availability is advisory only. Finalization in #12 remains
/// authoritative and may reject a line that this read model shows as available.
String? menuUnavailableReason(Menu menu) {
  if (menu.archived) {
    return 'Archived';
  }
  if (menu.variants.isEmpty) {
    return 'No variants';
  }
  if (menu.variants.every((variant) => !variant.enabled)) {
    return 'Unavailable';
  }
  if (menu.variants.every(
    (variant) => variant.availableUnits != null && variant.availableUnits! <= 0,
  )) {
    return 'Out of stock';
  }
  return null;
}

bool menuHasSelectableVariant(Menu menu) {
  return menu.variants.any(variantIsSelectable);
}

/// The lowest price among selectable variants, falling back to all variants.
int menuDisplayPriceMinor(Menu menu) {
  final prices = menu.variants
      .where(variantIsSelectable)
      .map((variant) => variant.priceMinor)
      .toList();
  if (prices.isNotEmpty) {
    prices.sort();
    return prices.first;
  }
  final all = menu.variants.map((variant) => variant.priceMinor).toList()
    ..sort();
  return all.isEmpty ? 0 : all.first;
}

/// Why a cart line can no longer be sold from the latest catalog read.
/// Lines are deliberately kept and marked instead of being deleted.
String? cartLineUnavailableReason(
  CatalogSnapshot? snapshot, {
  required String menuId,
  required String variantId,
}) {
  if (snapshot == null) {
    return null;
  }
  final menu = snapshot.menuById(menuId);
  if (menu == null) {
    return 'Item is no longer available';
  }
  if (menu.archived) {
    return 'Item archived';
  }
  final variant = snapshot.variantById(menuId, variantId);
  if (variant == null) {
    return 'Variant is no longer available';
  }
  return variantUnavailableReason(variant);
}
