import '../../core/network/http_client.dart';
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
  /// Retorna uma lista de [ProductModel].
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

  /// Cria um novo produto via POST.
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _httpClient.post(
      '$_baseUrl/products', 
      product.toJson()
    );
    
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  /// Atualiza um produto existente via PUT.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _httpClient.put(
      '$_baseUrl/products/${product.id}', 
      product.toJson()
    );
    
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  /// Deleta um produto pelo ID via DELETE.
  Future<void> deleteProduct(int id) async {
    await _httpClient.delete('$_baseUrl/products/$id');
  }
}

