import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
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

  /// Carrega produtos do repositório com retries opcionais.
  /// Atualiza o estado para carregando, então sucesso ou erro conforme o resultado.
  Future<void> loadProducts({int maxRetries = 1}) async {
    _state.value = _state.value.copyWith(isLoading: true, error: null);

    for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
      try {
        final products = await _repository.getProducts();

        // Preserva o estado de favoritos dos produtos já carregados
        final currentFavorites = {
          for (final p in _state.value.products) p.id: p.favorite,
        };
        final merged = products.map((p) {
          final wasFavorite = currentFavorites[p.id];
          return wasFavorite != null ? p.copyWith(favorite: wasFavorite) : p;
        }).toList();

        _state.value = _state.value.copyWith(
          isLoading: false,
          products: merged,
          error: null,
        );
        return;
      } on Failure catch (e) {
        if (attempt <= maxRetries) {
          developer.log('ViewModel retry $attempt/$maxRetries: ${e.message}');
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }
        String errorMsg = e.message;
        if (errorMsg.contains('523') || errorMsg.contains('unavailable')) {
          errorMsg += ' (Tente novamente ou verifique conexão/VPN/proxy)';
        }
        _state.value = _state.value.copyWith(isLoading: false, error: errorMsg);
        return;
      } catch (e) {
        if (attempt <= maxRetries) {
          developer.log('ViewModel retry $attempt/$maxRetries: $e');
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }
        _state.value = _state.value.copyWith(
          isLoading: false,
          error: 'Não foi possível carregar os produtos',
        );
        return;
      }
    }
  }

  /// Alterna o status de favorito de um produto pelo ID.
  void toggleFavorite(int productId) {
    final currentProducts = _state.value.products;

    final updatedProducts = currentProducts.map((product) {
      if (product.id == productId) {
        return product.copyWith(favorite: !product.favorite);
      }
      return product;
    }).toList();

    _state.value = _state.value.copyWith(products: updatedProducts);
  }

  /// Alterna o filtro de favoritos.
  void toggleFavoritesFilter() {
    _state.value = _state.value.copyWith(
      showOnlyFavorites: !_state.value.showOnlyFavorites,
    );
  }

  /// Prepara formulário para criar/editar produto.
  void setSelectedProduct(Product? product) {
    _state.value = _state.value.copyWith(
      selectedProduct: product,
      formError: null,
    );
  }

  /// Cria um novo produto.
  /// Retorna o produto criado (remoto ou local). Nunca relança em salvas locais.
  Future<Product> createProduct(Product product) async {
    _state.value = _state.value.copyWith(isSubmitting: true, formError: null);

    try {
      final created = await _repository.createProduct(product);
      await loadProducts(maxRetries: 0);
      setSelectedProduct(null);
      _state.value = _state.value.copyWith(isSubmitting: false);
      return created;
    } on Failure catch (e) {
      if (e.isLocalSave) {
        // Salvo localmente: trata como sucesso — form vai fechar normalmente
        await loadProducts(maxRetries: 0);
        setSelectedProduct(null);
        _state.value = _state.value.copyWith(isSubmitting: false);
        return product.copyWith(isPending: true);
      }
      _state.value = _state.value.copyWith(
        isSubmitting: false,
        formError: e.message,
      );
      rethrow;
    } catch (e) {
      _state.value = _state.value.copyWith(
        isSubmitting: false,
        formError: 'Erro inesperado ao criar produto',
      );
      rethrow;
    }
  }

  /// Atualiza produto existente.
  /// Retorna o produto atualizado (remoto ou local). Nunca relança em salvas locais.
  Future<Product> updateProduct(Product product) async {
    print('[VM] updateProduct: id=${product.id} title="${product.title}"');
    _state.value = _state.value.copyWith(isSubmitting: true, formError: null);

    try {
      final updated = await _repository.updateProduct(product);
      print('[VM] updateProduct: sucesso remoto, rodando loadProducts');
      await loadProducts(maxRetries: 0);
      setSelectedProduct(null);
      _state.value = _state.value.copyWith(isSubmitting: false);
      return updated;
    } on Failure catch (e) {
      print('[VM] updateProduct Failure: isLocalSave=${e.isLocalSave} msg="${e.message}"');
      if (e.isLocalSave) {
        print('[VM] updateProduct: salvo localmente, rodando loadProducts');
        await loadProducts(maxRetries: 0);
        print('[VM] updateProduct: loadProducts ok, produtos na lista: ${_state.value.products.length}');
        setSelectedProduct(null);
        _state.value = _state.value.copyWith(isSubmitting: false);
        return product.copyWith(isPending: true);
      }
      _state.value = _state.value.copyWith(
        isSubmitting: false,
        formError: e.message,
      );
      rethrow;
    } catch (e) {
      print('[VM] updateProduct UNEXPECTED: $e');
      _state.value = _state.value.copyWith(
        isSubmitting: false,
        formError: 'Erro inesperado ao atualizar produto',
      );
      rethrow;
    }
  }

  /// Deleta produto pelo ID.
  Future<void> deleteProduct(int id) async {
    _state.value = _state.value.copyWith(isLoading: true);

    try {
      await _repository.deleteProduct(id);
    } on Failure catch (e) {
      if (!e.isLocalSave) {
        _state.value = _state.value.copyWith(isLoading: false, error: e.message);
        rethrow;
      }
      // isLocalSave: item já oculto via pendingDeletes, trata como sucesso
    } finally {
      _state.value = _state.value.copyWith(isLoading: false);
      await loadProducts(maxRetries: 0);
    }
  }

  /// Limpa erros do formulário.
  void clearFormError() {
    _state.value = _state.value.copyWith(formError: null);
  }

  /// Libera o ViewModel e seus recursos.
  void dispose() {
    _state.dispose();
  }
}
