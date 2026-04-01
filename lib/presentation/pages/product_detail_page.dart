import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_form_page.dart';

/// Tela de detalhes de um produto selecionado.
/// Recebe o produto via construtor e exibe suas informações completas.
class ProductDetailPage extends StatelessWidget {
  final Product product;
  final ProductViewModel viewModel;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => viewModel.toggleFavorite(product.id),
            icon: Icon(
              product.favorite ? Icons.star : Icons.star_border,
              color: product.favorite ? Colors.amber[700] : null,
            ),
            tooltip: product.favorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem centralizada
              Center(
                child: SizedBox(
                  height: 260,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categoria
              if (product.category != null)
                Chip(
                  label: Text(product.category!),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                ),
              const SizedBox(height: 12),

              // Nome
              Text(
                product.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Preço
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Descrição
              if (product.description != null) ...[
                Text(
                  'Descrição',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Botão voltar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        viewModel.setSelectedProduct(product);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductFormPage(viewModel: viewModel),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => viewModel.deleteProduct(product.id),
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
