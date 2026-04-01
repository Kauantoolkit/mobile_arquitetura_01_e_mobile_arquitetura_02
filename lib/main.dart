import 'package:flutter/material.dart';

import 'core/network/http_client.dart';
import 'services/product_service.dart';
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
    // 1. Cria o HttpClient
    final httpClient = HttpClient();

    // 2. Cria o serviço de produtos
    final productService = ProductService(httpClient: httpClient);

    // 3. Cria o ViewModel e carrega os produtos
    final viewModel = ProductViewModel(service: productService);
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
