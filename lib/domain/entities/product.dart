/// Entidade imutável representando um produto.
/// Este é o objeto central de domínio usado em toda a aplicação.
class Product {
  /// Identificador único do produto.
  final int id;

  /// Título ou nome do produto.
  final String title;

  /// Preço do produto.
  final double price;

  /// String da URL da imagem do produto.
  final String image;

  /// Indica se o produto está marcado como favorito.
  final bool favorite;

  /// Cria um Product imutável com as propriedades informadas.
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.favorite = false,
  });

  /// Cria uma cópia deste produto com os campos informados substituídos.
  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? image,
    bool? favorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          price == other.price &&
          image == other.image &&
          favorite == other.favorite;

  @override
  int get hashCode => Object.hash(id, title, price, image, favorite);

  @override
  String toString() =>
      'Product(id: $id, title: $title, price: $price, image: $image, favorite: $favorite)';
}

