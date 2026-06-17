import 'package:country_code_picker/country_code_picker.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/constant/show_toast_dialog.dart';
import 'package:eatsipy_customer/controllers/signup_controller.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/round_button_fill.dart';
import 'package:eatsipy_customer/themes/text_field_widget.dart';
import 'package:eatsipy_customer/utils/dynamic_traslator.dart';
import 'package:eatsipy_customer/utils/translation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: SignupController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        "Create an Account 🚀",
                        style: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: 'Urbanist', fontWeight: FontWeight.w600),
                      ),
                      TranslatedText(
                        "Sign up to start your food adventure with Eatsipy",
                        style: TextStyle(color: isDark ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: 'Urbanist'),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              title: 'First Name',
                              controller: controller.firstNameEditingController.value,
                              hintText: 'Enter First Name',
                              prefix: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_user.svg",
                                  colorFilter: ColorFilter.mode(
                                    isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                              title: 'Last Name',
                              controller: controller.lastNameEditingController.value,
                              hintText: 'Enter Last Name',
                              prefix: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_user.svg",
                                  colorFilter: ColorFilter.mode(
                                    isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextFieldWidget(
                        title: 'Email Address',
                        textInputType: TextInputType.emailAddress,
                        controller: controller.emailEditingController.value,
                        enable: controller.type.value == "google" || controller.type.value == "apple" ? false : true,
                        hintText: 'Enter Email Address',
                        prefix: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            "assets/icons/ic_mail.svg",
                            colorFilter: ColorFilter.mode(
                              isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      TextFieldWidget(
                        title: 'Phone Number',
                        controller: controller.phoneNUmberEditingController.value,
                        hintText: 'Enter Phone Number',
                        enable: controller.type.value == "mobileNumber" ? false : true,
                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        prefix: ValueListenableBuilder(
                            valueListenable: TranslationNotifier.refresh,
                            builder: (_, __, ___) {
                              return CountryCodePicker(
                                headerText: 'Select Country'.tr,
                                onInit: (value) {
                                  controller.countryCodeEditingController.value.text = value?.dialCode ?? Constant.defaultCountryCode;
                                  controller.countryISOCodeEditingController.value.text = value?.code ?? Constant.defaultCountryCode;
                                },
                                enabled: controller.type.value == "mobileNumber" ? false : true,
                                onChanged: (value) {
                                  controller.countryCodeEditingController.value.text = value.dialCode.toString();
                                  controller.countryISOCodeEditingController.value.text = value.code.toString();
                                },
                                dialogTextStyle: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: 'Urbanist'),
                                dialogBackgroundColor: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                                initialSelection: controller.countryISOCodeEditingController.value.text,
                                comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                textStyle: TextStyle(fontSize: 14, color: isDark ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: 'Urbanist', fontWeight: FontWeight.w500),
                                searchDecoration: InputDecoration(iconColor: isDark ? AppThemeData.grey50 : AppThemeData.grey900),
                                searchStyle: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: 'Urbanist'),
                              );
                            }),
                      ),
                      controller.type.value == "google" || controller.type.value == "apple" || controller.type.value == "mobileNumber"
                          ? const SizedBox()
                          : Column(
                              children: [
                                TextFieldWidget(
                                  title: 'Password',
                                  controller: controller.passwordEditingController.value,
                                  hintText: 'Enter Password',
                                  obscureText: controller.passwordVisible.value,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_lock.svg",
                                      colorFilter: ColorFilter.mode(
                                        isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: InkWell(
                                        onTap: () {
                                          controller.passwordVisible.value = !controller.passwordVisible.value;
                                        },
                                        child: controller.passwordVisible.value
                                            ? SvgPicture.asset(
                                                "assets/icons/ic_password_show.svg",
                                                colorFilter: ColorFilter.mode(
                                                  isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/ic_password_close.svg",
                                                colorFilter: ColorFilter.mode(
                                                  isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )),
                                  ),
                                ),
                                TextFieldWidget(
                                  title: 'Confirm Password',
                                  controller: controller.conformPasswordEditingController.value,
                                  hintText: 'Enter Confirm Password',
                                  obscureText: controller.conformPasswordVisible.value,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_lock.svg",
                                      colorFilter: ColorFilter.mode(
                                        isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: InkWell(
                                        onTap: () {
                                          controller.conformPasswordVisible.value = !controller.conformPasswordVisible.value;
                                        },
                                        child: controller.conformPasswordVisible.value
                                            ? SvgPicture.asset(
                                                "assets/icons/ic_password_show.svg",
                                                colorFilter: ColorFilter.mode(
                                                  isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/ic_password_close.svg",
                                                colorFilter: ColorFilter.mode(
                                                  isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )),
                                  ),
                                ),
                              ],
                            ),
                      TextFieldWidget(
                        title: 'Referral Code(Optional)',
                        controller: controller.referralCodeEditingController.value,
                        hintText: 'Referral Code(Optional)',
                      ),
                      RoundedButtonFill(
                        title: "Signup",
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        onPress: () async {
                          if (controller.type.value == "google" || controller.type.value == "apple" || controller.type.value == "mobileNumber") {
                            if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter first name");
                            } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter last name");
                            } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter valid email");
                            } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Phone number");
                            } else {
                              controller.signUpWithEmailAndPassword();
                            }
                          } else {
                            if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter first name");
                            } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter last name");
                            } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter valid email");
                            } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Phone number");
                            } else if (controller.passwordEditingController.value.text.trim().length < 6) {
                              ShowToastDialog.showToast("Please enter minimum 6 characters password");
                            } else if (controller.passwordEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter password");
                            } else if (controller.conformPasswordEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Confirm password");
                            } else if (controller.passwordEditingController.value.text.trim() != controller.conformPasswordEditingController.value.text.trim()) {
                              ShowToastDialog.showToast("Password and Confirm password doesn't match");
                            } else {
                              controller.signUpWithEmailAndPassword();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
