import 'package:bulkretail/app/core/network/api_client.dart';
import 'package:bulkretail/app/core/network/api_endpoints.dart';
import 'package:bulkretail/app/data/models/products_model.dart';

abstract class IProductRepository {
  Future<ProductsModel> getProducts({required int limit, required int skip});
}

class ProductRepository implements IProductRepository {
  final ApiClient _client;

  ProductRepository(this._client);

  @override
  Future<ProductsModel> getProducts({required int limit, required int skip}) {
    return _client.handleRequest(
      () => _client.dio.get(
        ApiEndpoint.productList,
        queryParameters: {'limit': limit, 'skip': skip},
      ),
      (dynamic data) => ProductsModel.fromJson(data),
      'Get Products',
    );
  }
}
