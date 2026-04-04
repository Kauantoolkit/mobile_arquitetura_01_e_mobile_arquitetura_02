import 'package:flutter/material.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_tile.dart';
import '../../domain/entities/product.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';

/// Página principal que exibe a lista de produtos.
/// Usa ValueListenableBuilder para observar mudanças de estado do ViewModel.
/// Stateful para auto-load on init.
class ProductPage extends StatefulWidget {
  /// O ViewModel que gerencia o estado do produto.
  final ProductViewModel viewModel;

  /// Cria uma ProductPage com o ViewModel informado.
  const ProductPage({super.key, required this.viewModel});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Auto-load products on page enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadProducts(maxRetries: 2);
    });
  }

  /// Mostra diálogo de confirmação para deletar produto.
  void _showDeleteDialog(
    BuildContext context,
    Product product,
    ProductViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja realmente excluir "${product.title}"?'),
            const SizedBox(height: 8),
            Text(
              'Esta ação não pode ser desfeita.',
              style: TextStyle(color: Colors.red[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produto excluído!')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botão de filtro de favoritos
          ValueListenableBuilder(
            valueListenable: widget.viewModel.state,
            builder: (context, state, child) {
              return IconButton(
                onPressed: () => widget.viewModel.toggleFavoritesFilter(),
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
            valueListenable: widget.viewModel.state,
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
        valueListenable: widget.viewModel.state,
        builder: (context, state, child) {
          // Exibe indicador de carregamento
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Exibe mensagem de erro - enhanced for network/cache
          if (state.error != null) {
            final errorContainsNetwork =
                state.error!.contains('523') ||
                state.error!.contains('network') ||
                state.error!.contains('unavailable');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      errorContainsNetwork
                          ? Icons.wifi_off
                          : Icons.error_outline,
                      size: 64,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              widget.viewModel.loadProducts(maxRetries: 3),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              widget.viewModel.loadProducts(maxRetries: 0),
                          icon: const Icon(Icons.folder),
                          label: const Text('Ver Local'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
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
                      onPressed: () => widget.viewModel.toggleFavoritesFilter(),
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
                    onPressed: () => widget.viewModel.loadProducts(),
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
              return GestureDetector(
                onLongPress: () =>
                    _showDeleteDialog(context, product, widget.viewModel),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        product: product,
                        viewModel: widget.viewModel,
                      ),
                    ),
                  );
                },
                child: ProductTile(
                  product: product,
                  onFavoriteToggle: () =>
                      widget.viewModel.toggleFavorite(product.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// FAB Novo Produto (prioridade)
          FloatingActionButton.extended(
            heroTag: 'new_product',
            onPressed: () {
              widget.viewModel.setSelectedProduct(null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormPage(viewModel: widget.viewModel),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Novo'),
            tooltip: 'Criar novo produto',
          ),
          const SizedBox(height: 12),

          /// FAB Refresh (secundário)
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () => widget.viewModel.loadProducts(maxRetries: 1),
            tooltip: 'Atualizar',
            child: const Icon(Icons.refresh),
            mini: true,
          ),
        ],
      ),
    );
  }
}
