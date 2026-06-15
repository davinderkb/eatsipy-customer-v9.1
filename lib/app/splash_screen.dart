import 'package:eatsipy_customer/controllers/splash_controller.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemeData.primary300,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/ic_home.svg",
                  width: 120,
                  height: 120,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                const SizedBox(
                  height: 20,
                ),
                TranslatedText(
                  "Welcome to Eatsipy",
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50, fontSize: 28, fontFamily: AppThemeData.bold),
                ),
                TranslatedText(
                  "Your Favorite Food Delivered Fast!",
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
