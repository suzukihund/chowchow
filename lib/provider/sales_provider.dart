import 'package:chowchow/repository/sales_repository.dart';
import 'package:chowchow/type/type.dart';
import 'package:hooks_riverpod/all.dart';

enum SpanType { daily, monthly }
final StateProvider<SpanType> spanProvider =
    StateProvider<SpanType>((ProviderReference ref) => SpanType.daily);

final Provider<SalesNotifier> salesProvider = Provider<SalesNotifier>((ref) {
  final repo = ref.read(salesRepository);
  return SalesNotifier(salesRepository: repo);
});

class SalesNotifier {
  const SalesNotifier({this.salesRepository});

  final SalesRepository salesRepository;

  void addSales(OrderInfo orderInfo) {
    salesRepository.addSales(orderInfo);
  }

  Future<List<SalesChartInfo>> sumSalesByDay(int daysNum) =>
      salesRepository.sumSalesByDay(daysNum);

  Future<List<SalesChartInfo>> sumSalesByMonth() =>
      salesRepository.sumSalesByMonth();

  Future<List<Order>> todayOrders() => salesRepository.todayOrders();
}

final spannedSalesProvider = Provider<Future<List<SalesChartInfo>>>((ref) {
  final spanType = ref.watch(spanProvider);
  final salesNotifier = ref.watch(salesProvider);

  switch (spanType.state) {
    case SpanType.daily:
      return salesNotifier.sumSalesByDay(30);
    case SpanType.monthly:
      return salesNotifier.sumSalesByMonth();
  }
  return Future.value(<SalesChartInfo>[]);
});
