import 'package:chowchow/provider/sales_provider.dart';
import 'package:chowchow/type/type.dart';
import 'package:chowchow/widget/button.dart';
import 'package:chowchow/widget/calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/all.dart';

class PaymentScreen extends HookWidget {
  PaymentScreen({@required this.orderInfo});

  final OrderInfo orderInfo;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final NumberFormat numberFormat = NumberFormat('#,###');
    final int total = orderInfo.billingAmount;
    final int tax = (total * 0.1).ceil();
    final ValueNotifier<int> receivedMoney = useState(0);
    final int remain = receivedMoney.value - (total + tax);
    String message;

    if (remain < 0) {
      message = '未決済 ¥ ${numberFormat.format(remain * -1)}';
    } else {
      message = 'お釣り ¥ ${numberFormat.format(remain)}';
    }

    return Material(
      color: const Color(0xac000000),
      child: Container(
        margin: const EdgeInsets.all(64),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(width: 8, color: Theme.of(context).primaryColor)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const Spacer(),
                Text('お支払い金額', style: Theme.of(context).textTheme.headline4),
                const Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.close, size: 48, color: Colors.black45),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('¥${numberFormat.format(total + tax)}',
                style: Theme.of(context).textTheme.headline2),
            Text('(内消費税 ¥$tax)', style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text('お預かり金額', style: Theme.of(context).textTheme.headline4),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _textEditingController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.end,
                    onSubmitted: (text) {
                      final int val = int.tryParse(text);
                      if (val != null) {
                        _textEditingController.text =
                            '¥ ${numberFormat.format(val)}';
                        receivedMoney.value = val;
                      }
                    },
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Calculator(
                  width: 300,
                  height: 250,
                  onType: (int num) {
                    _textEditingController.text =
                        '¥ ${numberFormat.format(num)}';
                    receivedMoney.value = num;
                  },
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Text(message, style: Theme.of(context).textTheme.headline4),
                const Spacer(),
                CCButton(
                    enabled: remain >= 0,
                    borderColor: Theme.of(context).primaryColor,
                    borderWidth: 4,
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 12, left: 24, right: 24),
                    child: Text('会計する',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: remain >= 0
                              ? Theme.of(context).primaryColor
                              : Colors.black45,
                        )),
                    onPressed: () {
                      orderInfo.depositAmount = receivedMoney.value;
                      context.read(salesProvider).addSales(orderInfo);
                      Navigator.of(context).pop(true);
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
