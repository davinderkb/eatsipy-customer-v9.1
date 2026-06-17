import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/dash_board_controller.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/translation_notifier.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: DashBoardController(),
        builder: (controller) {
          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvokedWithResult: (didPop, _) {
              final now = DateTime.now();
              if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                controller.currentBackPressTime = now;
                controller.canPopNow.value = false;
                ShowToastDialog.showToast("Double press to exit");
                return;
              } else {
                controller.canPopNow.value = true;
              }
            },
            child: Scaffold(
              body: controller.pageList.isEmpty ? SizedBox() : controller.pageList[controller.selectedIndex.value],
              bottomNavigationBar: ValueListenableBuilder(
                  valueListenable: TranslationNotifier.refresh,
                  builder: (_, __, ___) {
                    return NavigationBar(
                      selectedIndex: controller.selectedIndex.value,
                      backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                      indicatorColor: AppThemeData.primary300.withValues(alpha: 0.20),
                      animationDuration: const Duration(milliseconds: 400),
                      elevation: 2,
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (int index) {
                        if (index == 0) {
                          Get.put(DashBoardController());
                        }
                        controller.selectedIndex.value = index;
                      },
                      destinations: Constant.walletSetting == false
                          ? [
                              _destination(isDark, assetIcon: "assets/icons/ic_home.svg", label: 'Home'),
                              _destination(isDark, assetIcon: "assets/icons/ic_fav.svg", label: 'Favourites'),
                              _destination(isDark, assetIcon: "assets/icons/ic_orders.svg", label: 'Orders'),
                              _destination(isDark, assetIcon: "assets/icons/ic_profile.svg", label: 'Profile'),
                            ]
                          : [
                              _destination(isDark, assetIcon: "assets/icons/ic_home.svg", label: 'Home'),
                              _destination(isDark, assetIcon: "assets/icons/ic_fav.svg", label: 'Favourites'),
                              _destination(isDark, assetIcon: "assets/icons/ic_wallet.svg", label: 'Wallet'),
                              _destination(isDark, assetIcon: "assets/icons/ic_orders.svg", label: 'Orders'),
                              _destination(isDark, assetIcon: "assets/icons/ic_profile.svg", label: 'Profile'),
                            ],
                    );
                  }),
            ),
          );
        });
  }

  NavigationDestination _destination(bool isDark, {required String assetIcon, required String label}) {
    return NavigationDestination(
      icon: SvgPicture.asset(
        assetIcon,
        height: 22,
        width: 22,
        colorFilter: ColorFilter.mode(
          isDark ? AppThemeData.grey300 : AppThemeData.grey600,
          BlendMode.srcIn,
        ),
      ),
      selectedIcon: SvgPicture.asset(
        assetIcon,
        height: 22,
        width: 22,
        colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
      ),
      label: label.tr,
    );
  }
}
