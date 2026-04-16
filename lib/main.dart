import 'package:flutter/material.dart';

import 'core/network/http_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/entities/product.dart';
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/product_page.dart';
import 'presentation/pages/product_detail_page.dart';
import 'presentation/pages/product_form_page.dart';

void main() {
  runApp(const MyApp());
}

/// Nomes das rotas nomeadas da aplicação.
abstract class AppRoutes {
  static const home = '/';
  static const products = '/products';
  static const productDetail = '/product/detail';
  static const productForm = '/product/form';
}

/// Widget principal da aplicação que configura a injeção de dependência.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ProductViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Configura injeção de dependência (DI manual)
    final httpClient = HttpClient();
    final remoteDatasource = ProductRemoteDatasource(httpClient: httpClient);
    final cacheDatasource = ProductCacheDatasource();
    final repository = ProductRepositoryImpl(
      remoteDatasource: remoteDatasource,
      cacheDatasource: cacheDatasource,
    );
    _viewModel = ProductViewModel(repository: repository);
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) => HomePage(viewModel: _viewModel),
              settings: settings,
            );
          case AppRoutes.products:
            return MaterialPageRoute(
              builder: (_) => ProductPage(viewModel: _viewModel),
              settings: settings,
            );
          case AppRoutes.productDetail:
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                product: product,
                viewModel: _viewModel,
              ),
              settings: settings,
            );
          case AppRoutes.productForm:
            return MaterialPageRoute(
              builder: (_) => ProductFormPage(viewModel: _viewModel),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => HomePage(viewModel: _viewModel),
              settings: settings,
            );
        }
      },
    );
  }
}
