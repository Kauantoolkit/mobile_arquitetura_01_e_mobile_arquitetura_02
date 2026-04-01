import '../../core/network/http_client.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

/// Fonte de dados remota para buscar produtos da API FakeStore.
class ProductRemoteDatasource {
  final HttpClient _httpClient;

  /// URL base para a API FakeStore.
  static const String _baseUrl = 'https://fakestoreapi.com';

  /// Cria um ProductRemoteDatasource com o HttpClient informado.
  ProductRemoteDatasource({required HttpClient httpClient})
    : _httpClient = httpClient;

  /// Busca todos os produtos da API remota.
  Future<List<ProductModel>> getProducts() async {
    final response = await _httpClient.get('$_baseUrl/products');

    if (response is List) {
      return response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Invalid response format');
    }
  }

  /// Envia um novo produto para a API (POST).
  Future<ProductModel> addProduct(Product product) async {
    final body = ProductModel.fromEntity(product).toJson()..remove('id');
    final response = await _httpClient.post('$_baseUrl/products', body);
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  /// Atualiza um produto existente na API (PUT).
  Future<ProductModel> updateProduct(Product product) async {
    final body = ProductModel.fromEntity(product).toJson();
    final response = await _httpClient.put(
      '$_baseUrl/products/${product.id}',
      body,
    );
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  /// Remove um produto da API (DELETE).
  Future<void> deleteProduct(int id) async {
    await _httpClient.delete('$_baseUrl/products/$id');
  }
}

