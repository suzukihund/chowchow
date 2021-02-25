import 'package:flutter/foundation.dart';
import 'package:chowchow/type/type.dart';
import 'package:chowchow/datastore/datastore.dart';
import 'package:hooks_riverpod/all.dart';

final Provider<SalesRepository> salesRepository = Provider<SalesRepository>(
    (_) => SalesRepository(localDataStore: SqlDataStore()));

class SalesRepository {
  const SalesRepository({@required this.localDataStore});

  final LocalDataStore localDataStore;

  void addSales(OrderInfo orderInfo) {
    localDataStore.addSales(orderInfo);
  }

  Future<List<SalesChartInfo>> sumSalesByDay(int daysNum) {
    final ed = DateTime.now();
    final sd = ed.add(Duration(days: -daysNum));
    return localDataStore.sumSalesByDay(
        sd.millisecondsSinceEpoch, ed.millisecondsSinceEpoch);
  }

  Future<List<SalesChartInfo>> sumSalesByMonth() {
    final ed = DateTime.now();
    final sd = ed.add(Duration(days: -365));
    return localDataStore.sumSalesByMonth(
        sd.millisecondsSinceEpoch, ed.millisecondsSinceEpoch);
  }

  Future<List<Order>> todayOrders() => localDataStore.todayOrders();
}
