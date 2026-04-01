import 'dart:developer' as developer;
import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
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

  /// Busca produtos da fonte remota, com fallback de cache + pendings.
  @override
  Future<List<Product>> getProducts() async {
    try {
      // Tenta buscar da fonte remota
      final products = await _remoteDatasource.getProducts();

      // Salva no cache para uso futuro
      _cacheDatasource.save(products);

      final pendings = _cacheDatasource
          .getPendingCreates()
          .map((m) => m.toEntity())
          .toList();
      return [
        ...pendings,
        ...products.map((model) => model.toEntity()).toList(),
      ];
    } on Failure {
      // Se a fonte remota falhar, tenta obter do cache
      final cachedProducts = _cacheDatasource.get();

      // Fallback: pendings + cache
      final pendings = _cacheDatasource
          .getPendingCreates()
          .map((m) => m.toEntity())
          .toList();
      final cached =
          cachedProducts?.map((model) => model.toEntity()).toList() ?? [];
      final all = [...pendings, ...cached];
      if (all.isNotEmpty) {
        developer.log('Using cached + pendings (remote failed)');
        return all;
      }

      // Relança a falha original se não houver cache disponível
      rethrow;
    } catch (e) {
      // Tenta usar cache em qualquer outra exceção
      final cachedProducts = _cacheDatasource.get();

      // Fallback: pendings + cache
      final pendings = _cacheDatasource
          .getPendingCreates()
          .map((m) => m.toEntity())
          .toList();
      final cached =
          cachedProducts?.map((model) => model.toEntity()).toList() ?? [];
      final all = [...pendings, ...cached];
      if (all.isNotEmpty) {
        developer.log('Using cached + pendings (unexpected error)');
        return all;
      }

      // Converte para Failure se ainda não for
      throw Failure('Failed to load products: ${e.toString()}');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product.copyWith(isPending: true));
      _cacheDatasource.savePendingCreate(model); // Save locally first

      // Try remote without isPending
      final remoteModel = ProductModel.fromEntity(
        model.copyWith(isPending: null),
      );
      final createdModel = await _remoteDatasource.createProduct(remoteModel);

      // Success: remove pending, invalidate list cache
      _cacheDatasource.removePendingCreate(model.id);
      _cacheDatasource.clear();

      return createdModel.toEntity();
    } catch (e) {
      // Fail: keep pending, notify user
      throw Failure('Failed to sync product (saved locally): ${e.toString()}');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final updatedModel = await _remoteDatasource.updateProduct(model);

      // Limpa cache após atualização
      _cacheDatasource.clear();

      return updatedModel.toEntity();
    } catch (e) {
      throw Failure('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _remoteDatasource.deleteProduct(id);

      // Limpa cache após deleção
      _cacheDatasource.clear();
    } catch (e) {
      throw Failure('Failed to delete product: ${e.toString()}');
    }
  }
}
