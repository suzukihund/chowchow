import 'package:chowchow/provider/product_provider.dart';
import 'package:chowchow/screen/product/product_edit_screen.dart';
import 'package:chowchow/screen/product/product_list_screen.dart';
import 'package:chowchow/type/type.dart';
import 'util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:flutter/material.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
  binding.window.physicalSizeTestValue = const Size(1600, 1600);
  binding.window.devicePixelRatioTestValue = 1.0;

  testWidgets('商品登録すると一覧に追加される', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productProvider.overrideWithProvider(StateNotifierProvider(((ref) =>
            ProductNotifier(productRepository: FakeProductRepository()))))
      ],
      child: MaterialApp(
        routes: <String, WidgetBuilder>{
          '/add_product': (_) => ProductEditScreen(),
        },
        home: ProductListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    // 未登録状態
    expect(find.text('商品は未登録です'), findsOneWidget);
    // +ボタンタップ
    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pumpAndSettle();
    expect(find.text('価格(税抜)'), findsOneWidget);
    // 文字入力
    await tester.enterText(find.byKey(const Key('edit_name')), 'hoge');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('edit_price')), '500');
    await tester.pumpAndSettle();
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();
    expect(find.text('hoge'), findsOneWidget);
    expect(find.text('¥500'), findsOneWidget);
  });

  testWidgets('登録商品があれば一覧で表示する', (WidgetTester tester) async {
    final repo = FakeProductRepository();
    repo.addProduct(
        Product(productId: 1, name: 'AAA', price: 100, colorCode: 0));
    repo.addProduct(
        Product(productId: 2, name: 'BBB', price: 200, colorCode: 0));
    repo.addProduct(
        Product(productId: 3, name: 'CCC', price: 300, colorCode: 0));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productProvider.overrideWithProvider(StateNotifierProvider(
            ((ref) => ProductNotifier(productRepository: repo))))
      ],
      child: const MaterialApp(
        home: ProductListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('AAA'), findsOneWidget);
    expect(find.text('¥200'), findsOneWidget);
    expect(find.text('CCC'), findsOneWidget);
  });

  testWidgets('登録商品を削除できる', (WidgetTester tester) async {
    final repo = FakeProductRepository();
    repo.addProduct(
        Product(productId: 1, name: 'AAA', price: 100, colorCode: 0));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productProvider.overrideWithProvider(StateNotifierProvider(
            ((ref) => ProductNotifier(productRepository: repo))))
      ],
      child: const MaterialApp(
        home: ProductListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('AAA'), findsOneWidget);
    // 削除
    await tester.tap(find.byKey(Key('delete_button_1')));
    await tester.pumpAndSettle();
    // 確認ダイアログ
    await tester.tap(find.byKey(const Key('dialog_delete')));
    await tester.pumpAndSettle();
    // 消えた
    expect(find.text('AAA'), findsNothing);
  });
}
