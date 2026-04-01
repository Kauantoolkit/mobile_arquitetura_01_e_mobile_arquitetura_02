import '../entities/product.dart';

/// Interface abstrata do repositório para operações de dados de produtos.
/// Define o contrato para buscar produtos das fontes de dados.
abstract class ProductRepository {
  /// Busca a lista de todos os produtos.
  /// Retorna uma lista de entidades [Product].
  /// Lança [Failure] se a operação falhar.
  Future<List<Product>> getProducts();

  /// Cria um novo produto.
  /// Retorna o [Product] criado pela API.
  /// Lança [Failure] se a operação falhar.
  Future<Product> createProduct(Product product);

  /// Atualiza um produto existente.
  /// Retorna o [Product] atualizado pela API. 
  /// Lança [Failure] se a operação falhar.
  Future<Product> updateProduct(Product product);

  /// Remove um produto pelo ID.
  /// Lança [Failure] se a operação falhar.
  Future<void> deleteProduct(int id);
}

