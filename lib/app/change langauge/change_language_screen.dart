import 'dart:convert';

import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/change_language_controller.dart';
import 'package:eatsipy_customer/services/localization_service.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/utils/dynamic_traslator.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:get/get.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: ChangeLanguageController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          "Change Language",
                          style: TextStyle(
                            fontSize: 24,
                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TranslatedText(
                          "Select your preferred language for a personalized app experience.",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: (1.1 / 1),
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1,
                            children: controller.languageList
                                .map(
                                  (data) => Obx(
                                    () => GestureDetector(
                                      onTap: () async {
                                        LocalizationService().changeLocale(data.slug.toString());
                                        Preferences.setString(Preferences.languageCodeKey, jsonEncode(data));
                                        controller.selectedLanguage.value = data;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            NetworkImageWidget(
                                              imageUrl: data.image.toString(),
                                              height: 80,
                                              width: 80,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            TranslatedText(
                                              "${data.title}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: controller.selectedLanguage.value.slug == data.slug
                                                    ? AppThemeData.primary300
                                                    : isDark
                                                        ? AppThemeData.grey400
                                                        : AppThemeData.grey500,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}
