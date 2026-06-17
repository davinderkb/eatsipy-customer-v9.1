import 'package:eatsipy_customer/app/favourite_screens/favourite_screen.dart';
import 'package:eatsipy_customer/app/home_screen/home_screen.dart';
import 'package:eatsipy_customer/app/home_screen/home_screen_two.dart';
import 'package:eatsipy_customer/app/order_list_screen/order_screen.dart';
import 'package:eatsipy_customer/app/profile_screen/profile_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    getInit();
  }

  Future<void> getInit() async {
    final home = Constant.theme == "theme_2" ? const HomeScreenTwo() : const HomeScreen();
    pageList.value = [
      home,
      const FavouriteScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ];
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}
