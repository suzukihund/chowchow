import 'package:flutter/foundation.dart';
import 'package:chowchow/datastore/datastore.dart';
import 'package:chowchow/type/type.dart';
import 'package:hooks_riverpod/all.dart';

final Provider<ProductRepository> productRepository =
    Provider<ProductRepository>(
        (ref) => ProductRepository(localDataStore: SqlDataStore()));

class ProductRepository {
  ProductRepository({@required this.localDataStore});

  LocalDataStore localDataStore;

  Future<List<Product>> getAllProducts() async => localDataStore.allProducts();

  Future<int> addProduct(Product product) async =>
      localDataStore.addProduct(product);

  Future<Product> productById(int productId) async =>
      localDataStore.productById(productId);

  Future<void> updateProduct(Product product) async =>
      localDataStore.updateProduct(product);

  Future<void> deleteProduct(int productId) async =>
      localDataStore.deleteProduct(productId);
}
