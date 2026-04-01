import '../core/network/http_client.dart';
import '../data/models/product_model.dart';
import '../domain/entities/product.dart';

/// Serviço que centraliza todas as chamadas de rede relacionadas a produtos.
/// Encapsula o [HttpClient] e expõe operações CRUD de alto nível.
class ProductService {
  final HttpClient _httpClient;

  static const String _baseUrl = 'https://fakestoreapi.com';

  ProductService({required HttpClient httpClient}) : _httpClient = httpClient;

  /// Retorna a lista completa de produtos (GET).
  Future<List<Product>> fetchProducts() async {
    final response = await _httpClient.get('$_baseUrl/products');

    if (response is! List) throw Exception('Formato de resposta inválido');

    return response
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  /// Envia um novo produto para o servidor (POST).
  Future<Product> addProduct(Product product) async {
    final body = ProductModel.fromEntity(product).toJson()..remove('id');
    final response = await _httpClient.post('$_baseUrl/products', body);
    return ProductModel.fromJson(response as Map<String, dynamic>).toEntity();
  }

  /// Atualiza um registro existente (PUT).
  Future<Product> updateProduct(Product product) async {
    final body = ProductModel.fromEntity(product).toJson();
    final response = await _httpClient.put('$_baseUrl/products/${product.id}', body);
    return ProductModel.fromJson(response as Map<String, dynamic>).toEntity();
  }

  /// Remove o produto da base (DELETE).
  Future<void> deleteProduct(String id) async {
    await _httpClient.delete('$_baseUrl/products/$id');
  }
}
