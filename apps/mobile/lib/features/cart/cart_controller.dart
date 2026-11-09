import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import 'cart_line.dart';
import 'cart_repository.dart';

class CartState {
  const CartState({this.lines = const []});

  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  int get lineCount => lines.length;

  /// Total units across lines, shown on the cart badge.
  int get itemCount => lines.fold(0, (total, line) => total + line.quantity);

  /// Display-only derived total in integer minor units. The server quote is
  /// authoritative when checkout is implemented in #12.
  int get totalMinor =>
      lines.fold(0, (total, line) => total + line.subtotalMinor);

  CartLine? find(String menuId, String variantId) {
    for (final line in lines) {
      if (line.menuId == menuId && line.variantId == variantId) {
        return line;
      }
    }
    return null;
  }

  CartState replace(CartLine line) {
    final next = <CartLine>[];
    var replaced = false;
    for (final existing in lines) {
      if (existing.key == line.key) {
        next.add(line);
        replaced = true;
      } else {
        next.add(existing);
      }
    }
    if (!replaced) {
      next.add(line);
    }
    return CartState(lines: List.unmodifiable(next));
  }

  CartState remove(String menuId, String variantId) {
    final key = '$menuId::$variantId';
    return CartState(
      lines: List.unmodifiable(lines.where((line) => line.key != key)),
    );
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return DriftCartRepository(ref.watch(appDatabaseProvider));
});

final cartControllerProvider =
    AsyncNotifierProvider.autoDispose<CartController, CartState>(
      CartController.new,
    );

/// Owns the unsent cart. Every mutation writes to Drift before publishing state
/// so a catalog refresh, process kill or 401 cannot silently drop work.
class CartController extends AsyncNotifier<CartState> {
  @override
  Future<CartState> build() async {
    final repository = ref.watch(cartRepositoryProvider);
    return CartState(lines: await repository.load());
  }

  Future<void> add({
    required Menu menu,
    required Variant variant,
    required String currency,
    required int currencyExponent,
  }) async {
    final current = await future;
    final existing = current.find(menu.id, variant.id);
    final nextQuantity = existing == null
        ? 1
        : _clampQuantity(existing.quantity + 1);

    final line = CartLine(
      menuId: menu.id,
      variantId: variant.id,
      itemName: menu.name,
      variantName: variant.name,
      unitPriceMinor: variant.priceMinor,
      quantity: nextQuantity,
      currency: currency,
      currencyExponent: currencyExponent,
    );

    final repository = ref.read(cartRepositoryProvider);
    await repository.save(line);
    state = AsyncData(current.replace(line));
  }

  Future<void> increment(String menuId, String variantId) async {
    final current = await future;
    final existing = current.find(menuId, variantId);
    if (existing == null) {
      return;
    }
    final line = existing.copyWith(
      quantity: _clampQuantity(existing.quantity + 1),
    );
    await ref.read(cartRepositoryProvider).save(line);
    state = AsyncData(current.replace(line));
  }

  /// Quantity never falls below 1. Removing a line is an explicit action.
  Future<void> decrement(String menuId, String variantId) async {
    final current = await future;
    final existing = current.find(menuId, variantId);
    if (existing == null || existing.quantity <= 1) {
      return;
    }
    final line = existing.copyWith(quantity: existing.quantity - 1);
    await ref.read(cartRepositoryProvider).save(line);
    state = AsyncData(current.replace(line));
  }

  Future<void> remove(String menuId, String variantId) async {
    final current = await future;
    await ref.read(cartRepositoryProvider).delete(menuId, variantId);
    state = AsyncData(current.remove(menuId, variantId));
  }

  Future<void> clear() async {
    await ref.read(cartRepositoryProvider).clear();
    state = const AsyncData(CartState());
  }

  int _clampQuantity(int quantity) {
    if (quantity < 1) {
      return 1;
    }
    if (quantity > CartLine.maxQuantity) {
      return CartLine.maxQuantity;
    }
    return quantity;
  }
}
