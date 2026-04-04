import '../models/product_model.dart';

/// Fonte de dados de cache em memória para produtos.
/// Fornece funcionalidade simples de cache para reduzir chamadas de rede.
class ProductCacheDatasource {
  /// Armazenamento interno para produtos em cache.
  List<ProductModel>? _cachedProducts;

  /// Produtos pendentes de criação remota.
  final List<ProductModel> _pendingCreates = [];

  /// Produtos pendentes de atualização remota.
  final List<ProductModel> _pendingUpdates = [];

  /// IDs de produtos pendentes de remoção remota.
  final Set<int> _pendingDeletes = {};

  // ── cache principal ──────────────────────────────────────────────────────

  /// Salva a lista de produtos no cache.
  void save(List<ProductModel> products) {
    _cachedProducts = products;
  }

  /// Recupera os produtos em cache.
  List<ProductModel>? get() => _cachedProducts;

  /// Limpa o cache de lista.
  void clear() {
    _cachedProducts = null;
  }

  // ── pending creates ──────────────────────────────────────────────────────

  void savePendingCreate(ProductModel product) => _pendingCreates.add(product);

  void removePendingCreate(int id) =>
      _pendingCreates.removeWhere((p) => p.id == id);

  void clearPendingCreates() => _pendingCreates.clear();

  List<ProductModel> getPendingCreates() => List.unmodifiable(_pendingCreates);

  // ── pending updates ──────────────────────────────────────────────────────

  void savePendingUpdate(ProductModel product) {
    _pendingUpdates.removeWhere((p) => p.id == product.id);
    _pendingUpdates.add(product);
  }

  void removePendingUpdate(int id) =>
      _pendingUpdates.removeWhere((p) => p.id == id);

  List<ProductModel> getPendingUpdates() => List.unmodifiable(_pendingUpdates);

  // ── pending deletes ──────────────────────────────────────────────────────

  void savePendingDelete(int id) => _pendingDeletes.add(id);

  void removePendingDelete(int id) => _pendingDeletes.remove(id);

  Set<int> getPendingDeletes() => Set.unmodifiable(_pendingDeletes);
}
