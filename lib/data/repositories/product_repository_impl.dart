import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_cache_datasource.dart';

/// Implementação de [ProductRepository] que coordena entre
/// fontes de dados remota e cache com lógica de fallback.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remoteDatasource;
  final ProductCacheDatasource _cacheDatasource;

  /// Cria um ProductRepositoryImpl com as fontes de dados informadas.
  ProductRepositoryImpl({
    required ProductRemoteDatasource remoteDatasource,
    required ProductCacheDatasource cacheDatasource,
  }) : _remoteDatasource = remoteDatasource,
       _cacheDatasource = cacheDatasource;

  @override
  Future<Product> addProduct(Product product) async {
    final model = await _remoteDatasource.addProduct(product);
    return model.toEntity();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = await _remoteDatasource.updateProduct(product);
    return model.toEntity();
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _remoteDatasource.deleteProduct(id);
  }

  /// Busca produtos da fonte remota, com fallback de cache.
  /// Se a fonte remota falhar e existir cache, retorna os dados em cache.
  /// Lança [Failure] se a fonte remota falhar e o cache estiver vazio.
  @override
  Future<List<Product>> getProducts() async {
    try {
      // Tenta buscar da fonte remota
      final products = await _remoteDatasource.getProducts();

      // Salva no cache para uso futuro
      _cacheDatasource.save(products);

      return products.map((model) => model.toEntity()).toList();
    } on Failure {
      // Se a fonte remota falhar, tenta obter do cache
      final cachedProducts = _cacheDatasource.get();

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        // Retorna dados em cache se disponível
        return cachedProducts.map((model) => model.toEntity()).toList();
      }

      // Relança a falha original se não houver cache disponível
      rethrow;
    } catch (e) {
      // Tenta usar cache em qualquer outra exceção
      final cachedProducts = _cacheDatasource.get();

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return cachedProducts.map((model) => model.toEntity()).toList();
      }

      // Converte para Failure se ainda não for
      throw Failure('Failed to load products: ${e.toString()}');
    }
  }
}

