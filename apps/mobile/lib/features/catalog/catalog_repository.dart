import 'package:dio/dio.dart';
import 'package:modern_pos_api_client/api.dart';

import 'catalog_models.dart';

/// Catalog read boundary. Kept abstract so widget tests can provide fixtures.
abstract interface class CatalogRepository {
  Future<CatalogSnapshot> load(String outletId);
}

/// Reads categories, the complete menu (paginated) and outlet currency rules.
///
/// Dio is used deliberately: the auth interceptor from #4 observes 401 responses
/// on this client, clears the session and returns the cashier to sign-in while
/// the Drift cart queue keeps unsent lines.
class HttpCatalogRepository implements CatalogRepository {
  HttpCatalogRepository(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  static const _pageLimit = 100;
  static const _maxPages = 50;

  @override
  Future<CatalogSnapshot> load(String outletId) async {
    final options = Options(headers: {'Authorization': 'Bearer $_accessToken'});
    final encodedOutlet = Uri.encodeComponent(outletId);

    final responses = await Future.wait<dynamic>([
      _dio.get<dynamic>(
        '/v1/outlets/$encodedOutlet/categories',
        options: options,
      ),
      _dio.get<dynamic>(
        '/v1/outlets/$encodedOutlet/settings',
        options: options,
      ),
    ]);

    final categories = Category.listFromJson(responses[0].data as dynamic);
    final settings = Settings.fromJson(responses[1].data);
    if (settings == null) {
      throw const FormatException('Invalid settings response');
    }

    final menus = <Menu>[];
    String? cursor;
    for (var page = 0; page < _maxPages; page++) {
      final response = await _dio.get<dynamic>(
        '/v1/outlets/$encodedOutlet/menu',
        queryParameters: {'limit': _pageLimit, 'cursor': ?cursor},
        options: options,
      );
      final parsed = MenuPage.fromJson(response.data);
      if (parsed == null) {
        throw const FormatException('Invalid catalog response');
      }
      menus.addAll(parsed.items);
      final next = parsed.nextCursor;
      if (next == null || next == cursor) {
        break;
      }
      cursor = next;
    }

    return CatalogSnapshot(
      categories: categories,
      menus: menus,
      currency: settings.currency,
      currencyExponent: settings.currencyExponent,
    );
  }
}
