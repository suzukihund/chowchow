import 'package:chowchow/provider/sales_provider.dart';
import 'package:chowchow/screen/cc_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chowchow/type/type.dart';
import 'package:intl/intl.dart';

class ReceiptListScreen extends HookWidget {
  final NumberFormat numberFormat = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return CCMaterial(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('伝票一覧', style: Theme.of(context).textTheme.headline4),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close, size: 36),
                  onPressed: Navigator.of(context).pop),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(),
              ),
              child: _createReceiptPane(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createReceiptPane(BuildContext context) {
    final orders = useProvider(salesProvider).todayOrders();
    return FutureBuilder<List<Order>>(
      future: orders,
      initialData: const <Order>[],
      builder: (BuildContext ctx, AsyncSnapshot<List<Order>> snapshot) {
        if (snapshot.hasData) {
          return _createReceiptList(context, snapshot.data);
        } else {
          return Center(
              child: Text('本日分の売上はまだありません',
                  style: Theme.of(context).textTheme.headline4));
        }
      },
    );
  }

  Widget _createReceiptList(BuildContext context, List<Order> orders) {
    return CustomScrollView(
      slivers: [
        SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
            const TextStyle textStyle = TextStyle(
              fontSize: 24,
              color: Colors.black87,
            );
            final Order order = orders[index];
            final DateTime dt =
                DateTime.fromMillisecondsSinceEpoch(order.sinceEpoch).toLocal();
            final int amount =
                order.billingAmount + (order.billingAmount * order.tax).ceil();

            return Container(
              padding: const EdgeInsets.only(left: 16, top: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black38)),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('伝票番号： ${order.orderId}', style: textStyle),
                      const SizedBox(width: 32),
                      Text(
                          '注文時間：${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                          style: textStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Text('合計金額：¥${numberFormat.format(amount)}',
                          style: textStyle),
                      const Spacer(),
                      Text('預かり金額：¥${numberFormat.format(order.depositAmount)}',
                          style: textStyle),
                      const Spacer(),
                      Text(
                          'お釣り：¥${numberFormat.format(order.depositAmount - amount)}',
                          style: textStyle),
                      const Spacer(),
                    ],
                  )
                ],
              ),
            );
          }, childCount: orders.length),
          itemExtent: 110,
        )
      ],
    );
  }
}
