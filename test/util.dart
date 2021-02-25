import 'package:chowchow/datastore/datastore.dart';
import 'package:chowchow/repository/product_repository.dart';
import 'package:chowchow/repository/sales_repository.dart';
import 'package:chowchow/type/type.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> dummyProducts = <Product>[];

  @override
  LocalDataStore localDataStore = StubDataStore();

  @override
  Future<int> addProduct(Product product) {
    dummyProducts.add(product);
    return Future<int>.value(dummyProducts.length);
  }

  @override
  Future<void> deleteProduct(int productId) {
    for (int i = 0; i < dummyProducts.length; i++) {
      if (dummyProducts[i].productId == productId) {
        dummyProducts.removeAt(i);
        break;
      }
    }
    return Future<void>.value(null);
  }

  @override
  Future<List<Product>> getAllProducts() {
    return Future<List<Product>>.value(dummyProducts);
  }

  @override
  Future<Product> productById(int productId) {
    for (Product p in dummyProducts) {
      if (p.productId == productId) {
        return Future<Product>.value(p);
      }
    }
    return Future<Product>.value(null);
  }

  @override
  Future<void> updateProduct(Product product) {
    for (int i = 0; i < dummyProducts.length; i++) {
      if (dummyProducts[i].productId == product.productId) {
        dummyProducts[i] = product;
        break;
      }
    }
    return Future<void>.value(null);
  }
}

class FakeSalesRepository implements SalesRepository {
  final List<OrderInfo> _orders = <OrderInfo>[];

  @override
  void addSales(OrderInfo orderInfo) {
    _orders.add(orderInfo);
  }

  @override
  LocalDataStore get localDataStore => StubDataStore();

  @override
  Future<List<SalesChartInfo>> sumSalesByDay(int daysNum) {
    return Future<List<SalesChartInfo>>.value([]);
  }

  @override
  Future<List<SalesChartInfo>> sumSalesByMonth() {
    return Future<List<SalesChartInfo>>.value([]);
  }

  @override
  Future<List<Order>> todayOrders() {
    final DateTime dt = DateTime.now();
    final List<Order> todays = <Order>[];
    for (int i = 0; i < _orders.length; i++) {
      todays.add(Order(
        orderId: i + 1,
        billingAmount: _orders[i].billingAmount,
        depositAmount: _orders[i].depositAmount,
        tax: 0.1,
        discount: 0,
        year: dt.year,
        month: dt.month,
        day: dt.day,
        hour: dt.hour,
        sinceEpoch: dt.millisecondsSinceEpoch,
      ));
    }
    return Future<List<Order>>.value(todays);
  }
}
