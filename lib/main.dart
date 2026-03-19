import 'package:flutter/material.dart';

import 'core/network/http_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

/// Widget principal da aplicação que configura a injeção de dependência.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configura injeção de dependência (DI manual)

    // 1. Cria o HttpClient
    final httpClient = HttpClient();

    // 2. Cria as fontes de dados
    final remoteDatasource = ProductRemoteDatasource(httpClient: httpClient);
    final cacheDatasource = ProductCacheDatasource();

    // 3. Cria o repositório
    final repository = ProductRepositoryImpl(
      remoteDatasource: remoteDatasource,
      cacheDatasource: cacheDatasource,
    );

    // 4. Cria o ViewModel
    final viewModel = ProductViewModel(repository: repository);

    // 5. Carrega produtos ao iniciar
    viewModel.loadProducts();

    return MaterialApp(
      title: 'App de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(viewModel: viewModel),
    );
  }
}
