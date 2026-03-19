import 'package:flutter/material.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_tile.dart';

/// Página principal que exibe a lista de produtos.
/// Usa ValueListenableBuilder para observar mudanças de estado do ViewModel.
class ProductPage extends StatelessWidget {
  /// O ViewModel que gerencia o estado do produto.
  final ProductViewModel viewModel;

  /// Cria uma ProductPage com o ViewModel informado.
  const ProductPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botão de filtro de favoritos
          ValueListenableBuilder(
            valueListenable: viewModel.state,
            builder: (context, state, child) {
              return IconButton(
                onPressed: () => viewModel.toggleFavoritesFilter(),
                icon: Icon(
                  state.showOnlyFavorites 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: state.showOnlyFavorites ? Colors.red : null,
                ),
                tooltip: state.showOnlyFavorites 
                    ? 'Mostrar todos' 
                    : 'Filtrar favoritos',
              );
            },
          ),
          // Contador de favoritos
          ValueListenableBuilder(
            valueListenable: viewModel.state,
            builder: (context, state, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '★ ${state.favoriteCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: viewModel.state,
        builder: (context, state, child) {
          // Exibe indicador de carregamento
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Exibe mensagem de erro
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.loadProducts(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista de produtos filtrada
          final products = state.filteredProducts;

          // Exibe mensagem quando não há produtos (após filtro)
          if (products.isEmpty) {
            if (state.showOnlyFavorites) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum produto favoritado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.toggleFavoritesFilter(),
                      icon: const Icon(Icons.list),
                      label: const Text('Mostrar todos'),
                    ),
                  ],
                ),
              );
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto encontrado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadProducts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Carregar produtos'),
                  ),
                ],
              ),
            );
          }

          // Constrói a lista de produtos filtrada
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductTile(
                product: product,
                onFavoriteToggle: () => viewModel.toggleFavorite(product.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.loadProducts(),
        tooltip: 'Atualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

