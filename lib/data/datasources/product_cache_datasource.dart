import '../models/product_model.dart';

/// Fonte de dados de cache em memória para produtos.
/// Fornece funcionalidade simples de cache para reduzir chamadas de rede.
class ProductCacheDatasource {
  /// Armazenamento interno para produtos em cache.
  List<ProductModel>? _cachedProducts;

  /// Produtos pendentes de criação remota.
  final List<ProductModel> _pendingCreates = [];

  /// Salva a lista de produtos no cache.
  void save(List<ProductModel> products) {
    _cachedProducts = products;
  }

  /// Salva um produto pendente de criação.
  void savePendingCreate(ProductModel product) {
    _pendingCreates.add(product);
  }

  /// Remove um produto pendente pelo ID.
  void removePendingCreate(int id) {
    _pendingCreates.removeWhere((p) => p.id == id);
  }

  /// Limpa pendings.
  void clearPendingCreates() {
    _pendingCreates.clear();
  }

  /// Getter público para pendings (readonly).
  List<ProductModel> getPendingCreates() => List.unmodifiable(_pendingCreates);

  /// Recupera os produtos em cache.
  /// Retorna null se nenhum produto estiver em cache.
  List<ProductModel>? get() {
    return _cachedProducts;
  }

  /// Limpa o cache de lista.
  void clear() {
    _cachedProducts = null;
  }
}
