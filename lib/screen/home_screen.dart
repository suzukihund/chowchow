import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_info/package_info.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String> versionStr = useState('');

    useEffect(() {
      PackageInfo.fromPlatform().then((info) {
        versionStr.value = info.version;
      });
      return null;
    }, const <void>[]);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Row(
              children: <Widget>[
                Flexible(child: _createLeftPane(context)),
                Flexible(child: _createRightPane(context)),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 16),
                Text('ver ${versionStr.value}',
                    style: Theme.of(context).textTheme.bodyText2),
                const Spacer(),
                FlatButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/license');
                  },
                  child: const Text('ライセンス',
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      )),
                ),
                const SizedBox(width: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _createLeftPane(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border:
              Border(right: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/regi');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.shop_outlined,
                    size: 64, color: Theme.of(context).primaryColor),
                Text('販売管理（レジ）', style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
        ));
  }

  Widget _createRightPane(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/product_list');
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text('商品登録', style: Theme.of(context).textTheme.headline4),
                ],
              ),
            ),
          ),
        )),
        Expanded(
            child: FlatButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/sales');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.bar_chart,
                    size: 64, color: Theme.of(context).primaryColor),
                Text('売上管理', style: Theme.of(context).textTheme.headline4),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
