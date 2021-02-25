import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef OnTypeNum = void Function(int);

class Calculator extends HookWidget {
  Calculator({this.width = 300, this.height = 400, this.onType});

  final double width;
  final double height;
  final OnTypeNum onType;
  final ValueNotifier<int> typedNum = useState<int>(0);
  final TextStyle textStyle = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final double w = (width - 2) / 3;
    final double h = (height - 3) / 4;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _createNumButton(context,
                  width: w, height: h, num: 7, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.white),
              _createNumButton(context,
                  width: w, height: h, num: 8, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.white),
              _createNumButton(context,
                  width: w, height: h, num: 9, onTypeNum: _updateNum),
            ],
          ),
          const Divider(height: 1, color: Colors.white),
          Row(
            children: <Widget>[
              _createNumButton(context,
                  width: w, height: h, num: 4, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.black),
              _createNumButton(context,
                  width: w, height: h, num: 5, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.black),
              _createNumButton(context,
                  width: w, height: h, num: 6, onTypeNum: _updateNum),
            ],
          ),
          const Divider(height: 1, color: Colors.white),
          Row(
            children: <Widget>[
              _createNumButton(context,
                  width: w, height: h, num: 1, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.black),
              _createNumButton(context,
                  width: w, height: h, num: 2, onTypeNum: _updateNum),
              const VerticalDivider(width: 1, color: Colors.black),
              _createNumButton(context,
                  width: w, height: h, num: 3, onTypeNum: _updateNum),
            ],
          ),
          const Divider(height: 1, color: Colors.white),
          Row(
            children: <Widget>[
              Container(
                width: w * 2,
                height: h,
                color: Colors.black26,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    typedNum.value = 0;
                    onType(0);
                  },
                  child: Center(child: Text('AC', style: textStyle)),
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              _createNumButton(context,
                  width: w, height: h, num: 0, onTypeNum: _updateNum),
            ],
          ),
        ],
      ),
    );
  }

  void _updateNum(int num) {
    if (typedNum.value > 0) {
      typedNum.value *= 10;
    }
    typedNum.value += num;
    onType(typedNum.value);
  }

  Widget _createNumButton(BuildContext context,
      {double width, double height, int num, OnTypeNum onTypeNum}) {
    return Container(
      width: width,
      height: height,
      color: Colors.black26,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          onTypeNum(num);
        },
        child: Center(
          child: Text(num.toString(), style: textStyle),
        ),
      ),
    );
  }
}
