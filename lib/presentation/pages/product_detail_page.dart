import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

/// Tela de detalhes de um produto selecionado.
/// Recebe o produto via construtor e exibe suas informações completas.
class ProductDetailPage extends StatelessWidget {
  final Product product;

  /// Callback para alternar o favorito (mantém sincronizado com a lista).
  final VoidCallback? onFavoriteToggle;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: onFavoriteToggle,
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
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
              const SizedBox(height: 12),

              // Nome
              Text(
                product.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar para a lista'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
