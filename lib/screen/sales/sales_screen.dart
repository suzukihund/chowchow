import 'package:chowchow/provider/sales_provider.dart';
import 'package:chowchow/screen/cc_scaffold.dart';
import 'package:chowchow/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:chowchow/type/type.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SalesScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final sales = useProvider(spannedSalesProvider);
    final spanType = useProvider(spanProvider);

    return CCScaffold(
      child: FutureBuilder<List<SalesChartInfo>>(
        future: sales,
        initialData: <SalesChartInfo>[],
        builder:
            (BuildContext ctx, AsyncSnapshot<List<SalesChartInfo>> snapshot) {
          if (snapshot.hasData) {
            final series = [
              charts.Series<SalesChartInfo, String>(
                id: 'Sales',
                colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
                domainFn: (SalesChartInfo info, _) => info.day.toString(),
                measureFn: (SalesChartInfo info, _) => info.sum,
                data: snapshot.data,
              )
            ];

            return Stack(
              children: <Widget>[
                Positioned.fill(child: charts.BarChart(series)),
                Positioned(
                  top: 32,
                  right: 32,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(4),
                    children: <Widget>[
                      Text('日', style: Theme.of(context).textTheme.headline5),
                      Text('月', style: Theme.of(context).textTheme.headline5),
                    ],
                    isSelected: <bool>[
                      spanType.state == SpanType.daily,
                      spanType.state == SpanType.monthly
                    ],
                    onPressed: (int index) {
                      if (index == 0)
                        spanType.state = SpanType.daily;
                      else
                        spanType.state = SpanType.monthly;
                    },
                    fillColor: Colors.yellow[100],
                  ),
                )
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
