import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chowchow/type/type.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class LocalDataStore {
  Future<void> open();
  void closeDatabase();

  Future<int> addProduct(Product product);
  Future<int> updateProduct(Product product);
  Future<int> deleteProduct(int productId);
  Future<List<Product>> allProducts();
  Future<Product> productById(int productId);

  Future<int> addSales(OrderInfo orderInfo);
  Future<List<SalesChartInfo>> sumSalesByDay(int fromEpoch, int toEpoch);
  Future<List<SalesChartInfo>> sumSalesByMonth(int fromEpoch, int toEpoch);

  Future<List<Order>> todayOrders();
}

const String DB_NAME = 'chowchow.db';
const String PRODUCT_TABLE = 'ProductTable';
const String ORDER_TABLE = 'OrderTable';
const String SALES_TABLE = 'SalesTable';
const String CATEGORY_TABLE = 'CategoryTable';

class SqlDataStore extends LocalDataStore {
  SqlDataStore._();

  static SqlDataStore _instance;
  Database _database;

  factory SqlDataStore() {
    return _instance ??= SqlDataStore._();
  }

  @override
  Future<void> open() async {
    if (_database != null) return Future<void>.value(null);

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DB_NAME);
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int ver) async {
      await db.execute(
          'CREATE TABLE $PRODUCT_TABLE (productId INTEGER PRIMARY KEY AUTOINCREMENT, categoryId INTEGER, name TEXT, price INTEGER, colorCode INTEGER, deleted BOOLEAN);');
      await db.execute(
          'CREATE TABLE $ORDER_TABLE (orderId INTEGER PRIMARY KEY AUTOINCREMENT, billingAmount INTEGER, depositAmount INTEGER, discount INTEGER, tax DOUBLE, year INTEGER, month INTEGER, day INTEGER, hour INTEGER, sinceEpoch INTEGER);');
      await db.execute(
          'CREATE TABLE $SALES_TABLE (orderId INTEGER, productId INTEGER, price INTEGER, quantity INTEGER, sinceEpoch INTEGER, PRIMARY KEY(orderId, productId));');
      await db.execute(
          'CREATE TABLE $CATEGORY_TABLE (categoryId INTEGER PRIMARY KEY, name TEXT, colorCode INTEGER);');
    });
  }

  @override
  void closeDatabase() {
    _database.close();
  }

  @override
  Future<int> addProduct(Product product) {
    return _database.insert(PRODUCT_TABLE, product.toMap());
  }

  @override
  Future<int> updateProduct(Product product) {
    return _database.update(PRODUCT_TABLE, product.toMap(),
        where: 'productId = ?', whereArgs: <dynamic>[product.productId]);
  }

  @override
  Future<int> deleteProduct(int productId) {
    return _database.update(PRODUCT_TABLE, <String, dynamic>{'deleted': 1},
        where: 'productId = ?', whereArgs: <dynamic>[productId]);
  }

  @override
  Future<List<Product>> allProducts() async {
    await open();

    final List<Map<String, dynamic>> maps =
        await _database.query(PRODUCT_TABLE, where: 'deleted = 0');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  @override
  Future<Product> productById(int productId) async {
    final List<Map<String, dynamic>> maps = await _database.query(PRODUCT_TABLE,
        where: 'productID = ?', whereArgs: <dynamic>[productId]);
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> addSales(OrderInfo orderInfo) async {
    await open();

    final DateTime dt = DateTime.now();
    final Order order = Order(
      billingAmount: orderInfo.billingAmount,
      depositAmount: orderInfo.depositAmount,
      discount: orderInfo.discount,
      tax: 0.1, // TODO: 税率10%固定。後々編集できるようにする
      year: dt.year,
      month: dt.month,
      day: dt.day,
      hour: dt.hour,
      sinceEpoch: dt.millisecondsSinceEpoch,
    );
    final orderId = await _database.insert(ORDER_TABLE, order.toMap());

    for (final OrderItem item in orderInfo.items) {
      final Sales sales = Sales(
        orderId: orderId,
        productId: item.product.productId,
        price: item.product.price,
        quantity: item.quantity,
        sinceEpoch: dt.millisecondsSinceEpoch,
      );
      await _database.insert(SALES_TABLE, sales.toMap());
    }
    return orderInfo.items.length;
  }

  @override
  Future<List<SalesChartInfo>> sumSalesByDay(int fromEpoch, int toEpoch) async {
    await open();

    final result = await _database.rawQuery(
        'SELECT year, month, day, SUM(billingAmount) FROM $ORDER_TABLE WHERE sinceEpoch BETWEEN $fromEpoch AND $toEpoch GROUP BY year, month, day');

    return _parseQueryResult(result);
  }

  @override
  Future<List<SalesChartInfo>> sumSalesByMonth(
      int fromEpoch, int toEpoch) async {
    await open();

    final result = await _database.rawQuery(
        'SELECT year, month, day, SUM(billingAmount) FROM $ORDER_TABLE WHERE sinceEpoch BETWEEN $fromEpoch AND $toEpoch GROUP BY year, month');

    return _parseQueryResult(result);
  }

  List<SalesChartInfo> _parseQueryResult(List<Map<String, dynamic>> maps) {
    List<SalesChartInfo> charts = <SalesChartInfo>[];
    for (var map in maps) {
      charts.add(SalesChartInfo(
        year: map['year'] as int,
        month: map['month'] as int,
        day: map['day'] as int,
        sum: map['SUM(billingAmount)'] as int,
      ));
    }
    return charts;
  }

  @override
  Future<List<Order>> todayOrders() async {
    final dt = DateTime.now();
    final result = await _database.query(ORDER_TABLE,
        where: 'year = ? AND month = ? AND day = ?',
        whereArgs: <dynamic>[dt.year, dt.month, dt.day],
        orderBy: 'orderId ASC');

    List<Order> orders = <Order>[];
    for (var r in result) {
      orders.add(Order.fromMap(r));
    }
    return orders;
  }
}

class StubDataStore extends LocalDataStore {
  List<Product> dummyProducts = <Product>[];
  List<Order> dummySales = <Order>[];

  @override
  Future<void> open() {}

  @override
  void closeDatabase() {}

  @override
  Future<int> addProduct(Product product) {
    dummyProducts.add(Product(
      productId: dummyProducts.length + 1,
      categoryId: product.categoryId,
      name: product.name,
      price: product.price,
      colorCode: product.colorCode,
    ));
    return Future<int>.value(dummyProducts.length);
  }

  @override
  Future<int> updateProduct(Product product) {
    for (int i = 0; i < dummyProducts.length; i++) {
      if (dummyProducts[i].productId == product.productId) {
        dummyProducts.removeAt(i);
        dummyProducts.insert(i, product);
      }
    }
    return Future<int>.value(1);
  }

  @override
  Future<int> deleteProduct(int productId) {
    for (int i = 0; i < dummyProducts.length; i++) {
      if (dummyProducts[i].productId == productId) {
        dummyProducts.removeAt(i);
        break;
      }
    }
    return Future<int>.value(1);
  }

  @override
  Future<List<Product>> allProducts() {
    final List<Product> items = <Product>[];
    final random = Random();
    for (int i = 0; i < 18; i++) {
      items.add(Product(
        productId: i + 1,
        name: 'ダミー($i)',
        price: random.nextInt(2000) + 100,
        colorCode: Colors.pink.value,
      ));
    }
    //return Future<List<Product>>.value(dummyProducts);
    return Future<List<Product>>.value(items);
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
  Future<int> addSales(OrderInfo orderInfo) {
    final DateTime dt = DateTime.now();

    final Order order = Order(
      orderId: dummySales.length + 1,
      billingAmount: orderInfo.billingAmount,
      depositAmount: orderInfo.depositAmount,
      discount: 0,
      tax: 0.1,
      year: dt.year,
      month: dt.month,
      day: dt.day,
      hour: dt.hour,
    );
    dummySales.add(order);

    return Future<int>.value(1);
  }

  @override
  Future<List<SalesChartInfo>> sumSalesByDay(int fromEpoch, int toEpoch) {
    final List<SalesChartInfo> result = <SalesChartInfo>[
/*      Sales(year: 2021, month: 2, day: 5, sales: 2290),
      Sales(year: 2021, month: 2, day: 6, sales: 2991),
      Sales(year: 2021, month: 2, day: 7, sales: 2280),*/
    ];
    final DateTime baseDt = DateTime.now();
    for (int i = 0; i < 10; i++) {
      DateTime dt = baseDt.add(Duration(days: -i));
      int sum = 0;
      for (Order o in dummySales) {
        if (o.year == dt.year && o.month == dt.month && o.day == dt.day) {
          sum += o.billingAmount;
        }
      }
      if (sum > 0) {
        //result.add(
        //   Sales(year: dt.year, month: dt.month, day: dt.day, sales: sum));
      }
    }

    return Future.value(result);
  }

  @override
  Future<List<Order>> todayOrders() {
    return Future.value(dummySales);
  }

  @override
  Future<List<SalesChartInfo>> sumSalesByMonth(int fromEpoch, int toEpoch) {
    // TODO: implement sumSalesByMonth
    throw UnimplementedError();
  }
}
