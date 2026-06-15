import 'package:eatsipy_customer/models/on_boarding_model.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  var selectedPageIndex = 0.obs;

  bool get isLastPage => selectedPageIndex.value == onBoardingList.length - 1;
  var pageController = PageController();

  @override
  void onInit() {
    getOnBoardingData();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<OnBoardingModel> onBoardingList = <OnBoardingModel>[].obs;

  getOnBoardingData() async {
    try {
      await FireStoreUtils.getOnBoardingList().then((value) {
        onBoardingList.value = value;
      });
    } catch (e) {
      onBoardingList.value = [];
    }
    isLoading.value = false;
    update();
  }
}
