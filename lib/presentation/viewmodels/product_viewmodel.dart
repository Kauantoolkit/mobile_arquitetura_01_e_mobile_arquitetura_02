import 'package:flutter/foundation.dart';
import '../../core/errors/failure.dart';
import '../../services/product_service.dart';
import '../../domain/entities/product.dart';
import 'product_state.dart';

/// ViewModel que gerencia o estado de carregamento de produtos e lógica de negócio.
/// Usa ValueNotifier para notificar ouvintes sobre mudanças de estado.
class ProductViewModel {
  final ProductService _service;

  final ValueNotifier<ProductState> _state = ValueNotifier(
    const ProductState(),
  );

  ValueNotifier<ProductState> get state => _state;

  ProductViewModel({required ProductService service}) : _service = service;

  /// Carrega produtos do serviço.
  Future<void> loadProducts() async {
    _state.value = _state.value.copyWith(isLoading: true, error: null);

    try {
      final products = await _service.fetchProducts();
      _state.value = _state.value.copyWith(
        isLoading: false,
        products: products,
        error: null,
      );
    } on Failure catch (e) {
      _state.value = _state.value.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      _state.value = _state.value.copyWith(
        isLoading: false,
        error: 'Não foi possível carregar os produtos',
      );
    }
  }

  /// Alterna o status de favorito de um produto pelo ID.
  void toggleFavorite(int productId) {
    final updated = _state.value.products.map((product) {
      if (product.id == productId) {
        return product.copyWith(favorite: !product.favorite);
      }
      return product;
    }).toList();
    _state.value = _state.value.copyWith(products: updated);
  }

  /// Cadastra um novo produto.
  /// Se offline, persiste localmente com isPending=true.
  Future<void> addProduct(Product product) async {
    try {
      final created = await _service.addProduct(product);
      // FakeStore sempre retorna id=21; usamos id negativo único para não colidir
      final localId = -DateTime.now().millisecondsSinceEpoch;
      final localProduct = created.copyWith(id: localId);
      final updated = [..._state.value.products, localProduct];
      _state.value = _state.value.copyWith(products: updated);
    } catch (_) {
      // Offline: adiciona à lista local como pendente
      final localId = -DateTime.now().millisecondsSinceEpoch;
      final localProduct = product.copyWith(id: localId, isPending: true);
      final updated = [..._state.value.products, localProduct];
      _state.value = _state.value.copyWith(products: updated);
    }
  }

  /// Atualiza um produto existente.
  /// Se offline, aplica a edição localmente com isPending=true.
  Future<void> updateProduct(Product product) async {
    try {
      await _service.updateProduct(product);
      final updated = _state.value.products.map((p) {
        return p.id == product.id ? product : p;
      }).toList();
      _state.value = _state.value.copyWith(products: updated);
    } catch (_) {
      // Offline: aplica a edição localmente como pendente
      final updated = _state.value.products.map((p) {
        return p.id == product.id ? product.copyWith(isPending: true) : p;
      }).toList();
      _state.value = _state.value.copyWith(products: updated);
    }
  }

  /// Remove um produto da lista pelo id.
  /// Se offline, remove localmente de qualquer forma.
  Future<void> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id.toString());
    } catch (_) {
      // Offline: remove localmente de qualquer forma
    } finally {
      final updated = _state.value.products.where((p) => p.id != id).toList();
      _state.value = _state.value.copyWith(products: updated);
    }
  }

  /// Alterna o filtro de favoritos.
  void toggleFavoritesFilter() {
    _state.value = _state.value.copyWith(
      showOnlyFavorites: !_state.value.showOnlyFavorites,
    );
  }

  /// Libera o ViewModel e seus recursos.
  void dispose() {
    _state.dispose();
  }
}
