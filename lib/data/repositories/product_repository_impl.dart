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
    List<ProductModel> base;
    try {
      base = await _remoteDatasource.getProducts();
      _cacheDatasource.save(base);
      print('[REPO] getProducts: remote OK (${base.length} produtos)');
    } on Failure catch (e) {
      final cached = _cacheDatasource.get();
      base = (cached != null && cached.isNotEmpty) ? cached : [];
      print('[REPO] getProducts: Failure remoto → cache=${base.length} itens | erro: ${e.message}');
    } catch (e) {
      final cached = _cacheDatasource.get();
      base = (cached != null && cached.isNotEmpty) ? cached : [];
      print('[REPO] getProducts: exceção remota → cache=${base.length} itens | $e');
    }

    final pendingUpdates = {
      for (final m in _cacheDatasource.getPendingUpdates()) m.id: m,
    };
    final pendingDeletes = _cacheDatasource.getPendingDeletes();
    final pendingCreates = _cacheDatasource.getPendingCreates();

    print('[REPO] getProducts: pendingCreates=${pendingCreates.length} pendingUpdates=${pendingUpdates.keys.toList()} pendingDeletes=${pendingDeletes.toList()}');

    // Aplica updates em produtos remotos/cache
    final mergedBase = base
        .where((m) => !pendingDeletes.contains(m.id))
        .map((m) => pendingUpdates[m.id] ?? m)
        .toList();

    // Aplica updates também em pending creates (produto criado offline e depois editado)
    final mergedCreates = pendingCreates
        .where((m) => !pendingDeletes.contains(m.id))
        .map((m) => pendingUpdates[m.id] ?? m)
        .toList();

    final all = [...mergedCreates, ...mergedBase];

    print('[REPO] getProducts: total final=${all.length}');

    if (all.isEmpty) {
      throw Failure('Falha ao carregar produtos e nenhum dado local disponível');
    }

    return all.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    // ID negativo único para não colidir com IDs reais da API
    final localId = -DateTime.now().millisecondsSinceEpoch;
    final localProduct = product.copyWith(id: localId, isPending: true);
    final model = ProductModel.fromEntity(localProduct);

    try {
      _cacheDatasource.savePendingCreate(model);
      print('[REPO] createProduct: salvo pendingCreate id=$localId title="${product.title}"');

      final remoteModel = ProductModel.fromEntity(product.copyWith(isPending: null));
      final createdModel = await _remoteDatasource.createProduct(remoteModel);
      print('[REPO] createProduct: remote OK id=${createdModel.id}');

      _cacheDatasource.removePendingCreate(localId);
      _cacheDatasource.clear();

      return createdModel.toEntity();
    } catch (e) {
      print('[REPO] createProduct: remote FALHOU → mantém pendingCreate id=$localId');
      throw Failure(
        'Produto salvo localmente (sem conexão).',
        isLocalSave: true,
      );
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    print('[REPO] updateProduct: id=${product.id} title="${product.title}"');
    final model = ProductModel.fromEntity(product.copyWith(isPending: true));
    _cacheDatasource.savePendingUpdate(model);
    print('[REPO] updateProduct: pendingUpdates agora=${_cacheDatasource.getPendingUpdates().map((m) => '${m.id}:${m.title}').toList()}');

    try {
      final remoteModel = ProductModel.fromEntity(
        product.copyWith(isPending: null),
      );
      print('[REPO] updateProduct: tentando remote...');
      final updatedModel = await _remoteDatasource.updateProduct(remoteModel);
      print('[REPO] updateProduct: remote OK');
      _cacheDatasource.removePendingUpdate(product.id);
      _cacheDatasource.clear();
      return updatedModel.toEntity();
    } catch (e) {
      print('[REPO] updateProduct: remote FALHOU ($e) → isLocalSave');
      throw Failure(
        'Atualização salva localmente (sem conexão).',
        isLocalSave: true,
      );
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    // Persiste localmente primeiro
    _cacheDatasource.savePendingDelete(id);

    try {
      await _remoteDatasource.deleteProduct(id);

      // Sucesso: remove pending e invalida cache
      _cacheDatasource.removePendingDelete(id);
      _cacheDatasource.clear();
    } catch (e) {
      throw Failure(
        'Exclusão salva localmente (sem conexão).',
        isLocalSave: true,
      );
    }
  }
}
