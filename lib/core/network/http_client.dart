import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/failure.dart';

/// Wrapper do cliente HTTP que encapsula as chamadas de rede.
/// Usa o pacote http para fazer requisições.
/// Lança [Failure] em erros de rede.
class HttpClient {
  final http.Client _client;

  /// Cria um HttpClient com um http.Client opcional.
  /// Se nenhum cliente for fornecido, um padrão é criado.
  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  /// Executa uma requisição GET para a URL informada.
  /// Retorna o corpo da resposta como dynamic (Map ou List).
  /// Lança [Failure] se a requisição falhar.
  Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Failure('Request failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Network error: ${e.toString()}');
    }
  }

  /// Executa uma requisição POST para a URL informada com o corpo JSON.
  /// Retorna o corpo da resposta como dynamic (Map ou List).
  /// Lança [Failure] se a requisição falhar.
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Failure('Request failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Network error: ${e.toString()}');
    }
  }

  /// Executa uma requisição PUT para a URL informada com o corpo JSON.
  /// Retorna o corpo da resposta como dynamic (Map ou List).
  /// Lança [Failure] se a requisição falhar.
  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Failure('Request failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Network error: ${e.toString()}');
    }
  }

  /// Executa uma requisição DELETE para a URL informada.
  /// Lança [Failure] se a requisição falhar.
  Future<void> delete(String url) async {
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Failure('Request failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Network error: ${e.toString()}');
    }
  }

  /// Fecha o cliente HTTP e libera recursos.
  void dispose() {
    _client.close();
  }
}

