import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_arquitetura_01/core/errors/failure.dart';
import 'package:mobile_arquitetura_01/domain/entities/product.dart';
import 'package:mobile_arquitetura_01/services/product_service.dart';
import 'package:mobile_arquitetura_01/presentation/viewmodels/product_viewmodel.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late ProductViewModel viewModel;
  late MockProductService mockService;

  setUp(() {
    mockService = MockProductService();
    viewModel = ProductViewModel(service: mockService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ProductViewModel', () {
    final testProducts = [
      const Product(
        id: 1,
        title: 'Product 1',
        price: 10.0,
        image: 'http://example.com/1.jpg',
      ),
      const Product(
        id: 2,
        title: 'Product 2',
        price: 20.0,
        image: 'http://example.com/2.jpg',
      ),
    ];

    test('Initial state should have isLoading as false and empty products', () {
      expect(viewModel.state.value.isLoading, false);
      expect(viewModel.state.value.products, isEmpty);
      expect(viewModel.state.value.error, isNull);
    });

    test('loadProducts should update state to loading', () async {
      when(
        () => mockService.fetchProducts(),
      ).thenAnswer((_) async => testProducts);

      final future = viewModel.loadProducts();

      expect(viewModel.state.value.isLoading, true);

      await future;
    });

    test('loadProducts should return products on success', () async {
      when(
        () => mockService.fetchProducts(),
      ).thenAnswer((_) async => testProducts);

      await viewModel.loadProducts();

      expect(viewModel.state.value.isLoading, false);
      expect(viewModel.state.value.products, testProducts);
      expect(viewModel.state.value.error, isNull);
      verify(() => mockService.fetchProducts()).called(1);
    });

    test('loadProducts should handle Failure and update error state', () async {
      when(
        () => mockService.fetchProducts(),
      ).thenThrow(const Failure('Network error'));

      await viewModel.loadProducts();

      expect(viewModel.state.value.isLoading, false);
      expect(viewModel.state.value.products, isEmpty);
      expect(viewModel.state.value.error, 'Network error');
    });

    test('loadProducts should handle generic exception and update error state', () async {
      when(
        () => mockService.fetchProducts(),
      ).thenThrow(Exception('Unexpected error'));

      await viewModel.loadProducts();

      expect(viewModel.state.value.isLoading, false);
      expect(viewModel.state.value.products, isEmpty);
      expect(
        viewModel.state.value.error,
        'Não foi possível carregar os produtos',
      );
    });

    test('loadProducts should notify listeners on state change', () async {
      var notificationCount = 0;
      viewModel.state.addListener(() {
        notificationCount++;
      });

      when(
        () => mockService.fetchProducts(),
      ).thenAnswer((_) async => testProducts);

      await viewModel.loadProducts();

      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });
}
