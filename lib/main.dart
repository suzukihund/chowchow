import 'package:chowchow/screen/product/product_edit_screen.dart';
import 'package:chowchow/screen/regi/receipt_list_screen.dart';
import 'package:chowchow/screen/regi/register_screen.dart';
import 'package:chowchow/screen/sales/sales_screen.dart';
import 'package:chowchow/type/type.dart';
import 'package:flutter/material.dart';
import 'package:chowchow/screen/home_screen.dart';
import 'package:hooks_riverpod/all.dart';

import 'package:chowchow/page_route.dart';
import 'package:chowchow/screen/product/product_list_screen.dart';
import 'package:chowchow/screen/regi/payment_screen.dart';

void main() {
  runApp(ProviderScope(child: ChowChowApp()));
}

class ChowChowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChowChow',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      routes: <String, WidgetBuilder>{
        '/product_list': (_) => const ProductListScreen(),
        '/regi': (_) => RegisterScreen(),
        '/sales': (_) => SalesScreen(),
        '/license': (_) => const LicensePage(),
      },
      onGenerateRoute: (RouteSettings routeSettings) {
        if (routeSettings.name == '/add_product') {
          return TransparentRoute<ProductEditScreen>(
              builder: (BuildContext ctx) {
            return ProductEditScreen();
          });
        } else if (routeSettings.name == '/edit_product') {
          final int productId = routeSettings.arguments as int;
          return TransparentRoute<ProductEditScreen>(
              builder: (BuildContext ctx) {
            return ProductEditScreen(productId: productId);
          });
        } else if (routeSettings.name == '/payment') {
          final OrderInfo info = routeSettings.arguments as OrderInfo;
          return TransparentRoute<PaymentScreen>(builder: (BuildContext ctx) {
            return PaymentScreen(orderInfo: info);
          });
        } else if (routeSettings.name == '/receipt_list') {
          return TransparentRoute<ReceiptListScreen>(
              builder: (BuildContext ctx) {
            return ReceiptListScreen();
          });
        }
        throw UnsupportedError('Unknown route');
      },
      home: HomeScreen(),
    );
  }
}
