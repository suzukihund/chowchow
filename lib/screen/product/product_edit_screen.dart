import 'package:chowchow/provider/product_provider.dart';
import 'package:chowchow/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:chowchow/type/type.dart';
import 'package:chowchow/screen/cc_material.dart';

typedef OnColorChanged = void Function(Color color);

class ProductEditScreen extends HookWidget {
  ProductEditScreen({this.productId = 0});

  final int productId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isValid = useState(false);
    final ValueNotifier<Product> editProduct =
        useState(Product(colorCode: Colors.purple[200].value));

    useEffect(() {
      if (productId != 0) {
        context.read(productProvider).productById(productId).then((value) {
          _nameController.text = value.name;
          _priceController.text = value.price.toString();
          editProduct.value = value;
        });
      }

      final VoidCallback callback = () {
        isValid.value = _validate();
      };

      _nameController.addListener(callback);
      _priceController.addListener(callback);

      return () {
        _nameController.removeListener(callback);
        _priceController.removeListener(callback);
      };
    }, const <void>[]);

    return CCMaterial(
        onScreenTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: <Widget>[
            _createHeader(context),
            const SizedBox(height: 32),
            _createEditNameRow(context),
            const SizedBox(height: 32),
            _createEditPriceRow(context),
            const SizedBox(height: 48),
            _createColorChooseRow(context,
                currentColor: Color(editProduct.value.colorCode),
                onColorChanged: (Color color) {
              final Product p = editProduct.value;
              editProduct.value = Product(
                productId: p.productId,
                name: p.name,
                price: p.price,
                colorCode: color.value,
              );
            }),
            const Spacer(),
            _createButtonsRow(context, isValid.value, editProduct.value),
          ],
        ));
  }

  Widget _createHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: const Icon(
              Icons.close,
              size: 48,
            ),
            onPressed: Navigator.of(context).pop),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget _createEditNameRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('商品名', style: Theme.of(context).textTheme.headline4),
        const SizedBox(width: 32),
        Expanded(
            child: TextField(
          key: const Key('edit_name'),
          controller: _nameController,
          style: Theme.of(context).textTheme.headline4,
          keyboardType: TextInputType.name,
        ))
      ],
    );
  }

  Widget _createEditPriceRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text('価格(税抜)', style: Theme.of(context).textTheme.headline4),
        Text('※消費税は会計時に加算します', style: Theme.of(context).textTheme.headline6),
        const SizedBox(width: 32),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text('¥', style: Theme.of(context).textTheme.headline4),
        ),
        Expanded(
            child: TextField(
          key: const Key('edit_price'),
          controller: _priceController,
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.end,
          keyboardType: TextInputType.number,
        ))
      ],
    );
  }

  Widget _createColorChooseRow(BuildContext context,
      {OnColorChanged onColorChanged, Color currentColor = Colors.purple}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text('表示色', style: Theme.of(context).textTheme.headline4),
        Text('※レジ画面で表示する色を選択します', style: Theme.of(context).textTheme.headline6),
        const SizedBox(width: 32),
        FlatButton(
            onPressed: () {
              _showColorPicker(context,
                  currentColor: currentColor, onColorChanged: onColorChanged);
            },
            child: Container(
              width: 50,
              height: 30,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(),
                color: currentColor,
              ),
            ))
      ],
    );
  }

  void _showColorPicker(BuildContext context,
      {Color currentColor, OnColorChanged onColorChanged}) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            content: SingleChildScrollView(
                child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                onColorChanged(color);
                Navigator.of(context).pop();
              },
            )),
          );
        });
  }

  Widget _createButtonsRow(
      BuildContext context, bool enabled, Product product) {
    final Color color = enabled
        ? Theme.of(context).primaryColor
        : Theme.of(context).disabledColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CCButton(
          enabled: enabled,
          padding:
              const EdgeInsets.only(top: 16, bottom: 16, left: 48, right: 48),
          borderColor: color,
          borderWidth: 4,
          onPressed: () async {
            final Product p = Product(
                productId: product.productId,
                name: _nameController.text,
                price: int.tryParse(_priceController.text) ?? 0,
                colorCode: product.colorCode);

            if (productId == 0) {
              await context.read(productProvider).addProduct(p);
            } else {
              await context.read(productProvider).updateProduct(p);
            }
            Navigator.of(context).pop();
          },
          child: Text(
            productId == 0 ? '登録' : '更新',
            style: TextStyle(
              fontSize: 32,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  bool _validate() {
    if (_nameController.text.isEmpty) return false;
    if (_priceController.text.isEmpty) return false;
    return true;
  }
}
