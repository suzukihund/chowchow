import 'package:chowchow/page_route.dart';
import 'package:chowchow/provider/sales_provider.dart';
import 'package:chowchow/screen/regi/register_screen.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'package:chowchow/provider/order_provider.dart';
import 'package:chowchow/provider/product_provider.dart';
import 'package:chowchow/type/type.dart';
import 'package:chowchow/screen/regi/payment_screen.dart';
import 'package:chowchow/screen/regi/receipt_list_screen.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
  binding.window.physicalSizeTestValue = const Size(1600, 1600);
  binding.window.devicePixelRatioTestValue = 1.0;

  final productRepo = FakeProductRepository();
  final salesRepo = FakeSalesRepository();

  setUp(() {
    productRepo.addProduct(
        Product(productId: 1, name: 'AAA', price: 100, colorCode: 0));
    productRepo.addProduct(
        Product(productId: 2, name: 'BBB', price: 200, colorCode: 0));
    productRepo.addProduct(
        Product(productId: 3, name: 'CCC', price: 300, colorCode: 0));
  });

  testWidgets('登録商品が一覧に表示され選択すると金額に加算される', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productProvider.overrideWithProvider(StateNotifierProvider(
            ((ref) => ProductNotifier(productRepository: productRepo))))
      ],
      child: MaterialApp(
        home: RegisterScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('こちらにお買い上げ商品が表示されます'), findsOneWidget);

    await tester.tap(find.text('BBB'));
    await tester.pumpAndSettle();
    expect(find.text('¥ 200'), findsOneWidget);
    expect(find.text('¥ 220'), findsOneWidget);
    expect(find.text('こちらにお買い上げ商品が表示されます'), findsNothing);

    await tester.tap(find.text('CCC'));
    await tester.tap(find.text('CCC'));
    await tester.pumpAndSettle();
    expect(find.text('¥ 600'), findsOneWidget);
    expect(find.text('¥ 880'), findsOneWidget);
  });

  testWidgets('+-ボタンで商品を増減できて０になると削除される', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productProvider.overrideWithProvider(StateNotifierProvider(
            ((ref) => ProductNotifier(productRepository: productRepo))))
      ],
      child: MaterialApp(
        home: RegisterScreen(),
      ),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.text('AAA'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('plus_1')));
    await tester.pumpAndSettle();
    expect(find.text('¥ 200'), findsOneWidget);

    await tester.tap(find.byKey(const Key('minus_1')));
    await tester.pumpAndSettle();
    expect(find.text('¥ 100'), findsOneWidget);

    await tester.tap(find.byKey(const Key('minus_1')));
    await tester.pumpAndSettle();
    expect(find.text('こちらにお買い上げ商品が表示されます'), findsOneWidget);
  });

  testWidgets('金額を入力してお支払いできる', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        salesProvider.overrideWithProvider(
            Provider(((ref) => SalesNotifier(salesRepository: salesRepo)))),
        productProvider.overrideWithProvider(StateNotifierProvider(
            ((ref) => ProductNotifier(productRepository: productRepo))))
      ],
      child: MaterialApp(
        onGenerateRoute: (routeSettings) {
          if (routeSettings.name == '/payment') {
            final OrderInfo info = routeSettings.arguments as OrderInfo;
            return TransparentRoute<PaymentScreen>(builder: (BuildContext ctx) {
              return PaymentScreen(orderInfo: info);
            });
          } else if (routeSettings.name == '/receipt_list') {
            return TransparentRoute<ReceiptListScreen>(
                builder: (BuildContext ctx) {
              return ReceiptListScreen();
            });
          } else {
            throw UnimplementedError();
          }
        },
        home: RegisterScreen(),
      ),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.text('AAA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('お支払い'));
    await tester.pumpAndSettle();

    expect(find.text('¥110'), findsOneWidget);
    expect(find.text('(内消費税 ¥10)'), findsOneWidget);
    expect(find.text('未決済 ¥ 110'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(find.text('未決済 ¥ 109'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    expect(find.text('お釣り ¥ 0'), findsOneWidget);

    await tester.tap(find.text('会計する'));
    await tester.pumpAndSettle();

    // 商品は空になる
    expect(find.text('こちらにお買い上げ商品が表示されます'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 伝票一覧へ
    await tester.tap(find.text('伝票一覧'));
    await tester.pumpAndSettle();

    expect(find.text('合計金額：¥110'), findsOneWidget);
  });

  testWidgets('伝票一覧を表示できる', (WidgetTester tester) async {});
}
