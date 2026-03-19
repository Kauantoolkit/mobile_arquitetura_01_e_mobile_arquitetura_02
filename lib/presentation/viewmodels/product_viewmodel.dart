import 'package:flutter/foundation.dart';
import '../../core/errors/failure.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

/// ViewModel que gerencia o estado de carregamento de produtos e lógica de negócio.
/// Usa ValueNotifier para notificar ouvintes sobre mudanças de estado.
class ProductViewModel {
  final ProductRepository _repository;

  /// StateNotifier que mantém o estado atual do produto.
  final ValueNotifier<ProductState> _state = ValueNotifier(
    const ProductState(),
  );

  /// Getter público para o estado a ser usado com ValueListenableBuilder.
  ValueNotifier<ProductState> get state => _state;

  /// Cria um ProductViewModel com o repositório informado.
  ProductViewModel({required ProductRepository repository})
    : _repository = repository;

  /// Carrega produtos do repositório.
  /// Atualiza o estado para carregando, então sucesso ou erro conforme o resultado.
  Future<void> loadProducts() async {
    // Define estado de carregamento
    _state.value = _state.value.copyWith(isLoading: true, error: null);

    try {
      final products = await _repository.getProducts();

      // Define estado de sucesso com produtos
      _state.value = _state.value.copyWith(
        isLoading: false,
        products: products,
        error: null,
      );
    } on Failure catch (e) {
      // Define estado de erro com mensagem de falha
      _state.value = _state.value.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      // Define estado de erro com mensagem genérica
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

