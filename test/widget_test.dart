import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_arquitetura_01/domain/entities/product.dart';
import 'package:mobile_arquitetura_01/services/product_service.dart';
import 'package:mobile_arquitetura_01/presentation/viewmodels/product_viewmodel.dart';
import 'package:mobile_arquitetura_01/presentation/pages/product_page.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService mockService;

  setUp(() {
    mockService = MockProductService();
  });

  group('ProductPage Widget Tests', () {
    testWidgets('should show error message when there is an error', (WidgetTester tester) async {
      when(() => mockService.fetchProducts()).thenThrow(
        Exception('Network error'),
      );

      final viewModel = ProductViewModel(service: mockService);

      await tester.pumpWidget(
        MaterialApp(home: ProductPage(viewModel: viewModel)),
      );

      await viewModel.loadProducts();
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os produtos'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('should show empty message when no products', (WidgetTester tester) async {
      when(() => mockService.fetchProducts()).thenAnswer((_) async => []);

      final viewModel = ProductViewModel(service: mockService);

      await tester.pumpWidget(
        MaterialApp(home: ProductPage(viewModel: viewModel)),
      );

      await viewModel.loadProducts();
      await tester.pumpAndSettle();

      expect(find.text('Nenhum produto encontrado'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('should show list of products when loaded successfully', (WidgetTester tester) async {
      final testProducts = [
        const Product(id: 1, title: 'Product 1', price: 10.0, image: 'http://example.com/1.jpg'),
        const Product(id: 2, title: 'Product 2', price: 20.0, image: 'http://example.com/2.jpg'),
      ];

      when(() => mockService.fetchProducts()).thenAnswer((_) async => testProducts);

      final viewModel = ProductViewModel(service: mockService);

      await tester.pumpWidget(
        MaterialApp(home: ProductPage(viewModel: viewModel)),
      );

      await viewModel.loadProducts();
      await tester.pumpAndSettle();

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('should have app bar with title', (WidgetTester tester) async {
      when(() => mockService.fetchProducts()).thenAnswer((_) async => []);

      final viewModel = ProductViewModel(service: mockService);

      await tester.pumpWidget(
        MaterialApp(home: ProductPage(viewModel: viewModel)),
      );

      await viewModel.loadProducts();
      await tester.pumpAndSettle();

      expect(find.text('Produtos'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('should have floating action button for new product', (WidgetTester tester) async {
      when(() => mockService.fetchProducts()).thenAnswer((_) async => []);

      final viewModel = ProductViewModel(service: mockService);

      await tester.pumpWidget(
        MaterialApp(home: ProductPage(viewModel: viewModel)),
      );

      await viewModel.loadProducts();
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      viewModel.dispose();
    });
  });
}
