import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../theme/app_theme.dart';
import '../cart/cart_controller.dart';
import 'catalog_controller.dart';
import 'catalog_models.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _query = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      setState(() => _query = value.trim());
    });
  }

  Future<void> _refresh() {
    return ref.read(catalogControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogControllerProvider);

    return catalog.when(
      loading: () => const _CatalogLoading(),
      error: (error, _) => _CatalogError(error: error, onRetry: _refresh),
      data: (snapshot) => RefreshIndicator(
        onRefresh: _refresh,
        child: _buildCatalog(context, snapshot),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, CatalogSnapshot snapshot) {
    final categories = snapshot.categories
        .where((category) => !category.archived)
        .toList(growable: false);
    final filtered = _filteredMenus(snapshot);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search menu',
            hintText: 'Item or variant',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: const Icon(Icons.close),
                  ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: PosColors.surface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (_) => setState(() => _selectedCategoryId = null),
                ),
              ),
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (_) => setState(
                      () => _selectedCategoryId =
                          _selectedCategoryId == category.id
                          ? null
                          : category.id,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (snapshot.menus.isEmpty)
          _EmptyCatalog(onRetry: _refresh)
        else if (filtered.isEmpty)
          const _NoMatches()
        else
          ..._catalogSections(context, snapshot, categories, filtered),
      ],
    );
  }

  List<Menu> _filteredMenus(CatalogSnapshot snapshot) {
    final query = _query.toLowerCase();
    return snapshot.menus
        .where((menu) {
          if (_selectedCategoryId != null &&
              menu.categoryId != _selectedCategoryId) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          if (menu.name.toLowerCase().contains(query) ||
              menu.description.toLowerCase().contains(query)) {
            return true;
          }
          return menu.variants.any(
            (variant) => variant.name.toLowerCase().contains(query),
          );
        })
        .toList(growable: false);
  }

  List<Widget> _catalogSections(
    BuildContext context,
    CatalogSnapshot snapshot,
    List<Category> categories,
    List<Menu> menus,
  ) {
    if (_selectedCategoryId != null || _query.isNotEmpty) {
      return [
        _ResultsSummary(count: menus.length),
        const SizedBox(height: 8),
        ..._sortedMenus(menus).map(
          (menu) => _MenuCard(
            menu: menu,
            snapshot: snapshot,
            onTap: () => _openMenu(snapshot, menu),
          ),
        ),
      ];
    }

    final knownCategoryIds = categories.map((category) => category.id).toSet();
    final widgets = <Widget>[];
    for (final category in categories) {
      final group = menus
          .where((menu) => menu.categoryId == category.id)
          .toList(growable: false);
      if (group.isEmpty) {
        continue;
      }
      widgets.add(_SectionHeader(title: category.name));
      widgets.addAll(
        _sortedMenus(group).map(
          (menu) => _MenuCard(
            menu: menu,
            snapshot: snapshot,
            onTap: () => _openMenu(snapshot, menu),
          ),
        ),
      );
    }

    final uncategorised = menus
        .where((menu) => !knownCategoryIds.contains(menu.categoryId))
        .toList(growable: false);
    if (uncategorised.isNotEmpty) {
      widgets.add(const _SectionHeader(title: 'Other'));
      widgets.addAll(
        _sortedMenus(uncategorised).map(
          (menu) => _MenuCard(
            menu: menu,
            snapshot: snapshot,
            onTap: () => _openMenu(snapshot, menu),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Menu> _sortedMenus(List<Menu> menus) {
    final sorted = [...menus]
      ..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );
    return sorted;
  }

  Future<void> _openMenu(CatalogSnapshot snapshot, Menu menu) async {
    if (menuUnavailableReason(menu) != null) {
      return;
    }

    if (menu.variants.length == 1) {
      await _addVariant(snapshot, menu, menu.variants.first);
      return;
    }

    final selected = await showModalBottomSheet<Variant>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _VariantSheet(menu: menu, snapshot: snapshot),
    );
    if (selected != null && mounted) {
      await _addVariant(snapshot, menu, selected);
    }
  }

  Future<void> _addVariant(
    CatalogSnapshot snapshot,
    Menu menu,
    Variant variant,
  ) async {
    final reason = variantUnavailableReason(variant);
    if (reason != null) {
      _showMessage('${menu.name} — $reason');
      return;
    }

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .add(
            menu: menu,
            variant: variant,
            currency: snapshot.currency,
            currencyExponent: snapshot.currencyExponent,
          );
      if (!mounted) {
        return;
      }
      _showMessage('Added ${menu.name}');
    } on Object {
      if (!mounted) {
        return;
      }
      _showMessage('Could not add item. Try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: PosColors.muted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ResultsSummary extends StatelessWidget {
  const _ResultsSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${count == 1 ? 'item' : 'items'}',
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: PosColors.muted),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.menu,
    required this.snapshot,
    required this.onTap,
  });

  final Menu menu;
  final CatalogSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reason = menuUnavailableReason(menu);
    final enabled = reason == null && menuHasSelectableVariant(menu);
    final price = snapshot.money.format(menuDisplayPriceMinor(menu));
    final variantLabel = menu.variants.length == 1
        ? menu.variants.first.name
        : '${menu.variants.length} variants';

    return Semantics(
      button: true,
      enabled: enabled,
      label:
          '${menu.name}, $price, $variantLabel'
          '${reason == null ? '' : ', unavailable, $reason'}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Opacity(
            opacity: enabled ? 1 : 0.6,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (menu.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            menu.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: PosColors.muted),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              price,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              variantLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: PosColors.muted),
                            ),
                          ],
                        ),
                        if (reason != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            reason,
                            style: const TextStyle(
                              color: PosColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      enabled
                          ? (menu.variants.length == 1
                                ? Icons.add_circle_outline
                                : Icons.playlist_add)
                          : Icons.block,
                      color: enabled ? PosColors.accent : PosColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VariantSheet extends StatelessWidget {
  const _VariantSheet({required this.menu, required this.snapshot});

  final Menu menu;
  final CatalogSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    menu.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Close variant selection',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Choose a variant to add.'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: menu.variants.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final variant = menu.variants[index];
                final reason = variantUnavailableReason(variant);
                final enabled = reason == null;
                return ListTile(
                  enabled: enabled,
                  minVerticalPadding: 14,
                  title: Text(variant.name),
                  subtitle: Text(
                    reason == null
                        ? snapshot.money.format(variant.priceMinor)
                        : '${snapshot.money.format(variant.priceMinor)} — $reason',
                    style: TextStyle(
                      color: reason == null
                          ? PosColors.muted
                          : PosColors.danger,
                    ),
                  ),
                  trailing: Icon(
                    enabled ? Icons.add_circle_outline : Icons.block,
                    color: enabled ? PosColors.accent : PosColors.muted,
                  ),
                  onTap: enabled
                      ? () => Navigator.of(context).pop(variant)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogLoading extends StatelessWidget {
  const _CatalogLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Loading menu'),
        ],
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = _isOffline(error);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(
          offline ? Icons.cloud_off : Icons.error_outline,
          size: 48,
          color: PosColors.danger,
        ),
        const SizedBox(height: 16),
        Text(
          offline ? 'You are offline' : 'Could not load menu',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          offline
              ? 'Reconnect and retry. Items already in the cart are kept.'
              : 'The menu could not be refreshed. Unsent cart lines are kept.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: PosColors.muted),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  bool _isOffline(Object error) {
    if (error is! DioException) {
      return false;
    }
    return error.response == null &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.unknown);
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu, size: 48, color: PosColors.muted),
          const SizedBox(height: 12),
          Text(
            'No menu items yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Add menu items in the back office, then retry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PosColors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: PosColors.muted),
          const SizedBox(height: 12),
          Text(
            'No matching items',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PosColors.muted),
          ),
        ],
      ),
    );
  }
}
