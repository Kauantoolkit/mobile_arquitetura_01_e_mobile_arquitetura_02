import '../../domain/entities/product.dart';

/// Modelo de dados para Product com serialização/deserialização JSON.
/// Estende a entidade de domínio [Product] com capacidades da camada de dados.
class ProductModel extends Product {
  /// Cria um ProductModel com as propriedades informadas.
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.image,
    super.favorite = false,
  });

  /// Cria um [ProductModel] a partir de um mapa JSON.
  /// Lança [FormatException] caso o JSON seja inválido ou ausente campos obrigatórios.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Valida se o JSON não é nulo

    // Valida e obtém o campo 'id'
    final id = json['id'];
    if (id == null) {
      throw const FormatException('Field "id" is required');
    }
    if (id is! int) {
      throw FormatException(
        'Field "id" must be an integer, got: ${id.runtimeType}',
      );
    }

    // Valida e obtém o campo 'title'
    final title = json['title'];
    if (title == null) {
      throw const FormatException('Field "title" is required');
    }
    if (title is! String) {
      throw FormatException(
        'Field "title" must be a string, got: ${title.runtimeType}',
      );
    }

    // Valida e obtém o campo 'price'
    final price = json['price'];
    if (price == null) {
      throw const FormatException('Field "price" is required');
    }
    if (price is! num) {
      throw FormatException(
        'Field "price" must be a number, got: ${price.runtimeType}',
      );
    }

    // Valida e obtém o campo 'image'
    final image = json['image'];
    if (image == null) {
      throw const FormatException('Field "image" is required');
    }
    if (image is! String) {
      throw FormatException(
        'Field "image" must be a string, got: ${image.runtimeType}',
      );
    }

    // Obtém o campo 'favorite' (opcional, padrão false)
    final favorite = json['favorite'] as bool? ?? false;

    return ProductModel(
      id: id,
      title: title,
      price: price.toDouble(),
      image: image,
      favorite: favorite,
    );
  }

  /// Converte este [ProductModel] para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'favorite': favorite,
    };
  }

  /// Cria um [ProductModel] a partir de uma entidade de domínio [Product].
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      favorite: product.favorite,
    );
  }

  /// Converte este modelo para uma entidade de domínio [Product].
  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      image: image,
      favorite: favorite,
    );
  }
}
