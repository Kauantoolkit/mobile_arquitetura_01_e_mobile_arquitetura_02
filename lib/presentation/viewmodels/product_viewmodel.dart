import 'package:flutter/foundation.dart';
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
    } catch (e) {
      _state.value = _state.value.copyWith(
        isLoading: false,
        error: 'Não foi possível carregar os produtos',
      );
    }
  }

  /// Alterna o status de favorito de um produto pelo ID.
  /// Atualiza a interface automaticamente através do ValueNotifier.
  void toggleFavorite(int productId) {
    final currentProducts = _state.value.products;
    
    // Atualiza a lista de produtos com o favorito alternado
    final updatedProducts = currentProducts.map((product) {
      if (product.id == productId) {
        // Cria uma cópia com o favorito alternado
        return product.copyWith(favorite: !product.favorite);
      }
      return product;
    }).toList();

    // Atualiza o estado com a nova lista de produtos
    _state.value = _state.value.copyWith(products: updatedProducts);
  }

  /// Cadastra um novo produto e adiciona à lista local.
  Future<void> addProduct(Product product) async {
    try {
      final created = await _service.addProduct(product);
      // A FakeStore retorna id=21 para todos os POSTs (API fake).
      // Usamos um id negativo único para não colidir com produtos reais.
      final localId = -DateTime.now().millisecondsSinceEpoch;
      final localProduct = created.copyWith(id: localId);
      final updated = [..._state.value.products, localProduct];
      _state.value = _state.value.copyWith(products: updated);
    } catch (e) {
      _state.value = _state.value.copyWith(error: 'Erro ao cadastrar produto');
    }
  }

  /// Atualiza um produto existente na lista local.
  Future<void> updateProduct(Product product) async {
    try {
      await _service.updateProduct(product);
      final updated = _state.value.products.map((p) {
        return p.id == product.id ? product : p;
      }).toList();
      _state.value = _state.value.copyWith(products: updated);
    } catch (e) {
      _state.value = _state.value.copyWith(error: 'Erro ao atualizar produto');
    }
  }

  /// Remove um produto da lista local pelo id.
  Future<void> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id.toString());
      final updated = _state.value.products.where((p) => p.id != id).toList();
      _state.value = _state.value.copyWith(products: updated);
    } catch (e) {
      _state.value = _state.value.copyWith(error: 'Erro ao remover produto');
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

