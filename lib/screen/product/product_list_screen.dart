import 'package:chowchow/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:chowchow/provider/product_provider.dart';
import 'package:chowchow/screen/cc_scaffold.dart';
import 'package:chowchow/type/type.dart';
import 'package:intl/intl.dart';

const double IdColWidth = 60;
const double ColorColWidth = 120;
const double TrushColWidth = 60;
const double RowHeight = 60;

class ProductListScreen extends HookWidget {
  const ProductListScreen();

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read(productProvider).sync();
      return null;
    }, const <void>[]);

    return CCScaffold(
      child: Container(
        child: Column(
          children: <Widget>[
            _createHeader(context),
            Expanded(child: _createBody(context))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_button'),
        onPressed: () {
          Navigator.of(context).pushNamed('/add_product');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _createHeader(BuildContext context) {
    return Container(
      height: RowHeight,
      decoration: BoxDecoration(
        color: Colors.purple[50],
        border:
            Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
      ),
      child: Row(
        children: _createRowItems(
          context,
          id: 'id',
          name: '商品名',
          price: '価格',
          colorItem: Text('表示色', style: Theme.of(context).textTheme.headline5),
          trashItem: Text('削除', style: Theme.of(context).textTheme.headline5),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    final List<Product> products = useProvider(productProvider.state);
    if (products.isEmpty) {
      return Center(
        child: Text('商品は未登録です', style: Theme.of(context).textTheme.headline4),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext ctx, int index) {
              return _createProductRow(context, products[index]);
            },
            childCount: products.length,
          ),
          itemExtent: RowHeight,
        ),
      ],
    );
  }

  Widget _createProductRow(BuildContext context, Product product) {
    final NumberFormat numberFormat = NumberFormat('#,###');
    final String price = numberFormat.format(product.price);

    final Widget row = Container(
      height: RowHeight,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
      ),
      child: Row(
        children: _createRowItems(context,
            id: product.productId.toString(),
            name: product.name,
            price: '¥$price',
            colorItem: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(), color: Color(product.colorCode)),
            ),
            trashItem: IconButton(
              key: Key('delete_button_${product.productId}'),
              onPressed: () {
                _confirmDeleteProduct(context, product);
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            )),
      ),
    );

    return FlatButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        Navigator.of(context)
            .pushNamed('/edit_product', arguments: product.productId);
      },
      child: row,
    );
  }

  List<Widget> _createRowItems(BuildContext context,
      {String id,
      String name,
      String price,
      Widget colorItem,
      Widget trashItem}) {
    final double priceW =
        (MediaQuery.of(context).size.width - (IdColWidth + ColorColWidth)) / 3;

    return <Widget>[
      SizedBox(
        width: IdColWidth,
        child: Center(
          child: Text(id, style: Theme.of(context).textTheme.headline5),
        ),
      ),
      VerticalDivider(color: Theme.of(context).primaryColor),
      Expanded(
        child: Center(
          child: Text(name, style: Theme.of(context).textTheme.headline5),
        ),
      ),
      VerticalDivider(color: Theme.of(context).primaryColor),
      SizedBox(
        width: priceW,
        child: Center(
          child: Text(price, style: Theme.of(context).textTheme.headline5),
        ),
      ),
      VerticalDivider(color: Theme.of(context).primaryColor),
      SizedBox(
        width: ColorColWidth,
        child: Center(
          child: colorItem,
        ),
      ),
      VerticalDivider(color: Theme.of(context).primaryColor),
      SizedBox(
        width: TrushColWidth,
        child: Center(
          child: trashItem,
        ),
      )
    ];
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            title: Text('${product.name}を削除してもよろしいですか？'),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Spacer(),
                  CCButton(
                    borderWidth: 1,
                    borderColor: Colors.black38,
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8, left: 16, right: 16),
                    onPressed: Navigator.of(ctx).pop,
                    child: Text('キャンセル',
                        style: Theme.of(context).textTheme.button),
                  ),
                  const SizedBox(width: 16),
                  CCButton(
                    borderWidth: 1,
                    borderColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8, left: 16, right: 16),
                    onPressed: () {
                      context
                          .read(productProvider)
                          .deleteProduct(product.productId);
                      Navigator.of(ctx).pop();
                    },
                    child: Text('削除',
                        key: const Key('dialog_delete'),
                        style: Theme.of(context).textTheme.button),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          );
        });
  }
}
