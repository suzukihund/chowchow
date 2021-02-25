import 'package:chowchow/repository/product_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:chowchow/type/type.dart';

final StateNotifierProvider<ProductNotifier> productProvider =
    StateNotifierProvider<ProductNotifier>((ref) {
  final ProductRepository repo = ref.read(productRepository);
  return ProductNotifier(productRepository: repo);
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier({@required this.productRepository}) : super(<Product>[]);

  final ProductRepository productRepository;

  Future<void> sync() async {
    state = await productRepository.getAllProducts();
  }

  Future<int> addProduct(Product product) async {
    final int ret = await productRepository.addProduct(product);
    await sync();
    return ret;
  }

  Future<Product> productById(int productId) async {
    return productRepository.productById(productId);
  }

  Future<void> updateProduct(Product product) async {
    await productRepository.updateProduct(product);
    await sync();
  }

  Future<void> deleteProduct(int productId) async {
    await productRepository.deleteProduct(productId);
    await sync();
  }
}
