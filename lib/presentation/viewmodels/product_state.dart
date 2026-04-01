import '../../domain/entities/product.dart';

/// Classe de estado representando o estado atual do carregamento de produtos.
class ProductState {
  /// Se os produtos estão sendo carregados atualmente.
  final bool isLoading;

  /// Se uma operação CRUD está em execução (formulário).
  final bool isSubmitting;

  /// Lista de produtos carregados.
  final List<Product> products;

  /// Produto selecionado para edição (null = create).
  final Product? selectedProduct;

  /// Mensagem de erro se o carregamento falhou, null caso contrário.
  final String? error;

  /// Erro específico do formulário.
  final String? formError;

  /// Se está mostrando apenas produtos favoritos.
  final bool showOnlyFavorites;

  /// Cria um ProductState com as propriedades informadas.
  /// Valores padrão são fornecidos para todos os campos.
  const ProductState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.products = const [],
    this.selectedProduct,
    this.error,
    this.formError,
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
    bool? isSubmitting,
    List<Product>? products,
    Product? selectedProduct,
    String? error,
    String? formError,
    bool? showOnlyFavorites,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      error: error ?? this.error,
      formError: formError ?? this.formError,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}

