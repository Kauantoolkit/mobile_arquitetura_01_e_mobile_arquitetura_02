# mobile_arquitetura_01

A Flutter project demonstrating clean architecture with data, domain, and presentation layers. Consumes the FakeStore API (https://fakestoreapi.com/products).

## Architecture

This project follows Clean Architecture principles with the following layers:

```
lib/
  core/
    errors/
      failure.dart          # Exception class for failures
    network/
      http_client.dart     # HTTP client wrapper using http package
  domain/
    entities/
      product.dart         # Product entity (immutable)
    repositories/
      product_repository.dart  # Abstract repository interface
  data/
    models/
      product_model.dart   # ProductModel with JSON serialization
    datasources/
      product_remote_datasource.dart   # Remote API data source
      product_cache_datasource.dart    # In-memory cache data source
    repositories/
      product_repository_impl.dart     # Repository implementation
  presentation/
    viewmodels/
      product_state.dart    # State class for products
      product_viewmodel.dart # ViewModel managing product state
    pages/
      product_page.dart     # Main page displaying products
    widgets/
      product_tile.dart    # Reusable product card widget
  main.dart                 # App entry point with DI setup
```

## HTTP Package Used

This project uses the **http** package (version 1.6.0) for making network requests. It's a simple, lightweight HTTP client for Dart/Flutter.

## How to Run

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Build for Android:**
   ```bash
   flutter build apk
   ```

4. **Build for iOS:**
   ```bash
   flutter build ios
   ```

## How to Test Network Failure

To test the error handling and caching behavior:

1. **Test with no internet:**
   - Disconnect your device/computer from the network
   - Tap the refresh button (FAB)
   - If products were loaded before, they'll appear from cache
   - If no products were loaded before, you'll see an error message

2. **Simulate network failure in code:**
   - You can modify the `ProductRemoteDatasource` to throw an exception
   - Or temporarily change the API URL to an invalid endpoint

## Error Handling

- **Network errors:** Display "Não foi possível carregar os produtos" message
- **Cache fallback:** If network fails but cache exists, displays cached products
- **Empty state:** Shows appropriate message when no products available

## Features

- ✅ Clean Architecture (data, domain, presentation layers)
- ✅ Consumes https://fakestoreapi.com/products
- ✅ In-memory caching for offline support
- ✅ Error handling with user-friendly messages
- ✅ Pull-to-refresh via FAB button
- ✅ Null safety
- ✅ Material Design 3

## Commits

- `init: flutter project mobile_arquitetura_01` - Initial Flutter project setup
- Additional commits for each layer implementation

## Version

v1.0.0

