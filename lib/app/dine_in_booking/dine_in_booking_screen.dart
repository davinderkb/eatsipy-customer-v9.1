import 'package:eatsipy_customer/app/dine_in_booking/dine_in_booking_details.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/dine_in_booking_controller.dart';
import 'package:eatsipy_customer/models/dine_in_booking_model.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../themes/app_them_data.dart';

class DineInBookingScreen extends StatelessWidget {
  const DineInBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: DineInBookingController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 0,
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
              title: TranslatedText(
                "Dine in Bookings",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: ShapeDecoration(
                            color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(120),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      controller.isFeature.value = true;
                                    },
                                    child: Container(
                                      decoration: controller.isFeature.value == false
                                          ? null
                                          : ShapeDecoration(
                                              color: AppThemeData.primary300,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: TranslatedText(
                                          "Upcoming",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                            color: controller.isFeature.value == false
                                                ? isDark
                                                    ? AppThemeData.grey400
                                                    : AppThemeData.grey500
                                                : isDark
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      controller.isFeature.value = false;
                                    },
                                    child: Container(
                                      decoration: controller.isFeature.value == true
                                          ? null
                                          : ShapeDecoration(
                                              color: AppThemeData.primary300,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: TranslatedText(
                                          "History",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                            color: controller.isFeature.value == true
                                                ? isDark
                                                    ? AppThemeData.grey400
                                                    : AppThemeData.grey500
                                                : isDark
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: controller.isFeature.value
                              ? controller.featureList.isEmpty
                                  ? Constant.showEmptyView(message: "Upcoming Booking not found.")
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      itemCount: controller.featureList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        DineInBookingModel dineBookingModel = controller.featureList[index];
                                        return itemView(isDark, context, dineBookingModel);
                                      },
                                    )
                              : controller.historyList.isEmpty
                                  ? Constant.showEmptyView(message: "History not found.")
                                  : ListView.builder(
                                      itemCount: controller.historyList.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        DineInBookingModel dineBookingModel = controller.historyList[index];
                                        return itemView(isDark, context, dineBookingModel);
                                      },
                                    ),
                        ),
                      )
                    ],
                  ),
          );
        });
  }

  itemView(bool isDark, BuildContext context, DineInBookingModel orderModel) {
    return InkWell(
      onTap: () {
        Get.to(const DineInBookingDetails(), arguments: {"bookingModel": orderModel});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Stack(
                        children: [
                          NetworkImageWidget(
                            imageUrl: orderModel.vendor!.photo.toString(),
                            fit: BoxFit.cover,
                            height: Responsive.height(10, context),
                            width: Responsive.width(20, context),
                          ),
                          Container(
                            height: Responsive.height(10, context),
                            width: Responsive.width(20, context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(0.00, 1.00),
                                end: const Alignment(0, -1),
                                colors: [Colors.black.withValues(alpha: 0), AppThemeData.grey900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            orderModel.status.toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Constant.statusColor(status: orderModel.status.toString()),
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TranslatedText(
                            orderModel.vendor!.title.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TranslatedText(
                            Constant.timestampToDateTime(orderModel.createdAt!),
                            style: TextStyle(
                              color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: MySeparator(color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Name",
                        style: TextStyle(
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TranslatedText(
                        "${orderModel.guestFirstName} ${orderModel.guestLastName}",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Guest Number",
                        style: TextStyle(
                          color: isDark ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TranslatedText(
                        orderModel.totalGuest.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: MySeparator(color: isDark ? AppThemeData.grey700 : AppThemeData.grey200),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/icons/ic_location.svg"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TranslatedText(
                        orderModel.vendor!.location.toString(),
                        style: TextStyle(
                          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
