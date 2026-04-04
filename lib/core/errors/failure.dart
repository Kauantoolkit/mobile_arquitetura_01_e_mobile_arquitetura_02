/// Classe de exceção que representa falhas na aplicação.
/// Usada para envolver erros da camada de dados e propagá-los para a apresentação.
class Failure implements Exception {
  final String message;

  /// Quando true, a operação falhou na API mas foi salva localmente.
  /// O ViewModel deve tratar isso como sucesso (fechar form, atualizar lista).
  final bool isLocalSave;

  const Failure(this.message, {this.isLocalSave = false});

  @override
  String toString() => 'Failure: $message';
}

