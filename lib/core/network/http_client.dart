import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../errors/failure.dart';

/// Wrapper do cliente HTTP que encapsula as chamadas de rede.
/// Usa o pacote http para fazer requisições.
/// Lança [Failure] em erros de rede.
class HttpClient {
  final http.Client _client;
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Cria um HttpClient com um http.Client opcional.
  /// Se nenhum cliente for fornecido, um padrão é criado.
  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  /// Executa uma requisição GET para a URL informada com retry e timeout.
  /// Retorna o corpo da resposta como dynamic (Map ou List).
  /// Lança [Failure] se a requisição falhar após retries.
  Future<dynamic> get(String url) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final responseFuture = _client
            .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
            .timeout(timeoutDuration);

        final response = await responseFuture;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return json.decode(response.body);
        } else if (response.statusCode >= 500) {
          final errorMsg =
              'Server temporarily unavailable (${response.statusCode}). Retrying... (${attempt}/$maxRetries)';
          if (attempt == maxRetries) {
            throw Failure(errorMsg + ' Check your connection or try later.');
          }
          throw Exception(errorMsg); // Retry
        } else {
          throw Failure('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        // Backoff: 1s, 2s, 4s
        final backoff = Duration(
          milliseconds: 1000 * pow(2, attempt - 1).toInt(),
        );
        await Future.delayed(backoff);
      }
    }
  }

  /// Executa uma requisição POST.
  /// Retorna o corpo da resposta como dynamic.
  Future<dynamic> post(String url, dynamic body) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Failure('POST failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('POST network error: ${e.toString()}');
    }
  }

  /// Executa uma requisição PUT.
  /// Retorna o corpo da resposta como dynamic.
  Future<dynamic> put(String url, dynamic body) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Failure('PUT failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('PUT network error: ${e.toString()}');
    }
  }

  /// Executa uma requisição DELETE.
  /// Retorna void se sucesso.
  Future<void> delete(String url) async {
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Failure('DELETE failed with status: ${response.statusCode}');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('DELETE network error: ${e.toString()}');
    }
  }

  /// Fecha o cliente HTTP e libera recursos.
  void dispose() {
    _client.close();
  }
}
