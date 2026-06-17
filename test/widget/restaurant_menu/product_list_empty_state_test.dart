import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/controllers/restaurant_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  setUpAll(initializeTestDatabase);

  testWidgets(
      'empty search results show empty state without stale category headers',
      (tester) async {
    final controller = RestaurantDetailsController()
      ..isSearchActive.value = true
      ..searchQuery.value = 'zzzz';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductListView(controller: controller)),
      ),
    );

    expect(find.text('No dishes found'), findsOneWidget);
    expect(find.text('Try a different dish name'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
  });
}
