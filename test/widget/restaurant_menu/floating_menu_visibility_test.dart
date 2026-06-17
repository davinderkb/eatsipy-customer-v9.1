import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/controllers/restaurant_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_models.dart';

void main() {
  setUpAll(initializeTestDatabase);

  Widget wrap(RestaurantDetailsController controller) {
    return MaterialApp(
      home: Scaffold(
        body: RestaurantMenuFloatingButton(controller: controller),
      ),
    );
  }

  RestaurantDetailsController controllerWithMenu() {
    final controller = RestaurantDetailsController();
    controller.isMenuLoading.value = false;
    controller.hasMenuLoadError.value = false;
    controller.productList.value =
        List.generate(10, (index) => testProduct(id: 'p$index'));
    controller.menuCategoryMetaList.value = const [
      MenuCategoryMeta(categoryId: 'a', categoryName: 'A', itemCount: 5),
      MenuCategoryMeta(categoryId: 'b', categoryName: 'B', itemCount: 5),
    ];
    return controller;
  }

  testWidgets('floating menu hides while search is active', (tester) async {
    final controller = controllerWithMenu()..isSearchActive.value = true;
    await tester.pumpWidget(wrap(controller));

    expect(find.text('Menu'), findsNothing);
  });

  testWidgets(
      'floating menu hides for small menus and appears for eligible menus',
      (tester) async {
    final controller = controllerWithMenu();
    controller.productList.value =
        List.generate(9, (index) => testProduct(id: 'p$index'));
    await tester.pumpWidget(wrap(controller));
    expect(find.text('Menu'), findsNothing);

    controller.productList.value =
        List.generate(10, (index) => testProduct(id: 'p$index'));
    await tester.pump();
    expect(find.text('Menu'), findsOneWidget);
  });
}
