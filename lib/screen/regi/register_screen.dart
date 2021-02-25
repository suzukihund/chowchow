import 'package:chowchow/provider/order_provider.dart';
import 'package:chowchow/provider/popup_provider.dart';
import 'package:chowchow/provider/product_provider.dart';
import 'package:chowchow/screen/cc_scaffold.dart';
import 'package:chowchow/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:chowchow/type/type.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final double leftW = MediaQuery.of(context).size.width / 3;
    return CCScaffold(
      child: Row(
        children: <Widget>[
          Container(
            width: leftW,
            child: Column(
              children: <Widget>[
                _createLeftHeader(context, leftW),
                Expanded(child: _createLeftPane(context)),
              ],
            ),
          ),
          VerticalDivider(color: Theme.of(context).primaryColor),
          Expanded(
            child: _createRightPane(context),
          ),
        ],
      ),
    );
  }

  Widget _createLeftPane(BuildContext context) {
    final OrderInfo orderInfo = useProvider(orderProvider.state);

    if (orderInfo.items.isEmpty) {
      return const Center(
        child: Text('こちらにお買い上げ商品が表示されます',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                color: Colors.black45,
                fontWeight: FontWeight.bold)),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFixedExtentList(
                  delegate:
                      SliverChildBuilderDelegate((BuildContext ctx, int index) {
                    final OrderItem item = orderInfo.items[index];
                    return _createOrderItemCell(context, item);
                  }, childCount: orderInfo.items.length),
                  itemExtent: 137),
            ],
          ),
        ),
        _createAmountPanel(context, orderInfo?.billingAmount ?? 0),
      ],
    );
  }

  Widget _createLeftHeader(BuildContext context, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: CCButton(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 48, right: 48),
        borderColor: Theme.of(context).primaryColor,
        borderWidth: 1,
        onPressed: () {
          Navigator.of(context).pushNamed('/receipt_list');
        },
        child: Text('伝票一覧',
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 24)),
      ),
    );
  }

  Widget _createOrderItemCell(BuildContext context, OrderItem item) {
    final NumberFormat numberFormat = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TiledButtons(height: 40, buttons: <Widget>[
                IconButton(
                    key: Key('minus_${item.product.productId}'),
                    icon: Icon(Icons.remove,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      context
                          .read(orderProvider)
                          .removeProduct(item.product.productId);
                    }),
                IconButton(
                    key: Key('plus_${item.product.productId}'),
                    icon:
                        Icon(Icons.add, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      context.read(orderProvider).addProduct(item.product);
                    }),
              ]),
            ],
          ),
          const Spacer(),
          Text(
            '¥ ${numberFormat.format(item.product.price * item.quantity)}',
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
    );
  }

  Widget _createAmountPanel(BuildContext context, int billingAmount) {
    // TODO: 税率10%固定。いずれ編集可能にする
    final int amount = (billingAmount + (billingAmount * 0.1)).ceil();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black45)),
      ),
      child: Row(
        children: <Widget>[
          Text('合計：', style: Theme.of(context).textTheme.headline5),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child:
                Text('¥ $amount', style: Theme.of(context).textTheme.headline4),
          ),
          Text(' (税込)', style: Theme.of(context).textTheme.headline6),
        ],
      ),
    );
  }

  Widget _createRightPane(BuildContext context) {
    final List<Product> products = useProvider(productProvider.state);
    final ProductNotifier notifier = useProvider(productProvider);
    useEffect(() {
      notifier.sync();
      return null;
    }, const <void>[]);

    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverGrid(
                  delegate:
                      SliverChildBuilderDelegate((BuildContext ctx, int index) {
                    return _createProductCell(context, products[index]);
                  }, childCount: products.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4)),
            ],
          ),
        ),
        _createPayButton(context),
      ],
    );
  }

  Widget _createProductCell(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 3, left: 3),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: Color(product.colorCode)),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: FlatButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            context.read(orderProvider).addProduct(product);
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(product.name,
                      style: Theme.of(context).textTheme.button),
                ),
              ),
              Container(
                height: 50,
                color: Color(product.colorCode),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createPayButton(BuildContext context) {
    final bool enabled = useProvider(orderProvider.state).items.isNotEmpty;
    final Color color =
        enabled ? Theme.of(context).primaryColor : Colors.black45;

    return Container(
      margin: const EdgeInsets.only(right: 32),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black45))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CCButton(
            onPressed: () async {
              final OrderInfo orderInfo = context.read(orderProvider.state);
              final ret = await Navigator.of(context)
                  .pushNamed('/payment', arguments: orderInfo);
              if (ret == true) {
                context.read(orderProvider).clear();
                context.read(popupProvider).showSnackBar('会計を完了しました');
              }
            },
            borderWidth: 1,
            borderColor: color,
            padding:
                const EdgeInsets.only(left: 36, right: 36, top: 16, bottom: 16),
            child: Text('お支払い', style: TextStyle(fontSize: 26, color: color)),
            enabled: enabled,
          )
        ],
      ),
    );
  }
}
