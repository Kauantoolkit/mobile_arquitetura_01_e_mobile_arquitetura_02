import '../entities/product.dart';

/// Interface abstrata do repositório para operações de dados de produtos.
/// Define o contrato para buscar produtos das fontes de dados.
abstract class ProductRepository {
  /// Busca a lista de todos os produtos.
  Future<List<Product>> getProducts();

  /// Cadastra um novo produto.
  /// Retorna o produto criado (com id atribuído pela API).
  Future<Product> addProduct(Product product);

  /// Atualiza um produto existente pelo id.
  /// Retorna o produto atualizado.
  Future<Product> updateProduct(Product product);

  /// Remove um produto pelo id.
  Future<void> deleteProduct(int id);
}

