import 'package:eatsipy_customer/app/auth_screen/login_screen.dart';
import 'package:eatsipy_customer/controllers/on_boarding_controller.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          body: controller.isLoading.value
              ? Constant.loader()
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(controller.selectedPageIndex.value == 0
                              ? "assets/images/image_1.png"
                              : controller.selectedPageIndex.value == 1
                                  ? "assets/images/image_2.png"
                                  : "assets/images/image_3.png"),
                          fit: BoxFit.cover)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.selectedPageIndex.call,
                              itemCount: controller.onBoardingList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/ic_home.svg",
                                        width: 72,
                                        height: 72,
                                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                      TranslatedText(
                                        "Eatsipy",
                                        style: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey50, fontSize: 24, fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      TranslatedText(
                                        controller.onBoardingList[index].title.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isDark ? AppThemeData.primary300 : AppThemeData.primary300,
                                          fontSize: 28,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TranslatedText(
                                        controller.onBoardingList[index].description.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isDark ? AppThemeData.grey600 : AppThemeData.grey300,
                                          fontSize: 16,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        RoundedButtonFill(
                          title: controller.onBoardingList.isEmpty || controller.isLastPage ? "Get Started" : "Next",
                          color: AppThemeData.primary300,
                          textColor: AppThemeData.grey50,
                          onPress: () {
                            if (controller.onBoardingList.isEmpty || controller.isLastPage) {
                              Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                              Get.offAll(const LoginScreen());
                            } else {
                              controller.pageController.jumpToPage(controller.selectedPageIndex.value + 1);
                            }
                          },
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
