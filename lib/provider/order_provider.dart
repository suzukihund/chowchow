import 'package:chowchow/type/type.dart';
import 'package:hooks_riverpod/all.dart';

final StateNotifierProvider<OrderProvider> orderProvider =
    StateNotifierProvider<OrderProvider>((ref) => OrderProvider());

class OrderProvider extends StateNotifier<OrderInfo> {
  OrderProvider() : super(OrderInfo());

  void addProduct(Product product) {
    final OrderInfo order = state;
    for (OrderItem item in order.items) {
      if (item.product.productId == product.productId) {
        item.quantity++;
        _updateBillingAmount(order);
        return;
      }
    }

    order.items.add(OrderItem(product: product, quantity: 1));
    _updateBillingAmount(order);
  }

  void removeProduct(int productId) {
    final OrderInfo order = state;
    for (OrderItem item in order.items) {
      if (item.product.productId == productId) {
        item.quantity--;
        if (item.quantity <= 0) {
          order.items.remove(item);
        }
        _updateBillingAmount(order);
        break;
      }
    }
  }

  void clear() {
    state = OrderInfo();
  }

  void _updateBillingAmount(OrderInfo orderInfo) {
    int amount = 0;
    for (final OrderItem item in orderInfo.items) {
      amount += item.product.price * item.quantity;
    }
    orderInfo.billingAmount = amount;
    state = orderInfo;
  }
}
