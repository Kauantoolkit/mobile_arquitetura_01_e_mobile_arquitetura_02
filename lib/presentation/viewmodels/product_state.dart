import '../../domain/entities/product.dart';

/// Classe de estado representando o estado atual do carregamento de produtos.
class ProductState {
  /// Se os produtos estão sendo carregados atualmente.
  final bool isLoading;

  /// Lista de produtos carregados.
  final List<Product> products;

  /// Mensagem de erro se o carregamento falhou, null caso contrário.
  final String? error;

  /// Se está mostrando apenas produtos favoritos.
  final bool showOnlyFavorites;

  /// Cria um ProductState com as propriedades informadas.
  /// Valores padrão são fornecidos para todos os campos.
  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.showOnlyFavorites = false,
  });

  /// Retorna o número de produtos favoritos.
  int get favoriteCount => products.where((p) => p.favorite).length;

  /// Retorna a lista de produtos filtrada conforme o filtro de favoritos.
  List<Product> get filteredProducts {
    if (showOnlyFavorites) {
      return products.where((p) => p.favorite).toList();
    }
    return products;
  }

  /// Cria uma cópia deste estado com os campos informados substituídos.
  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool? showOnlyFavorites,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}

