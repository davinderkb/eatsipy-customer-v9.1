import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/cashback_controller.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:get/get.dart';

class CashbackOffersListScreen extends StatelessWidget {
  const CashbackOffersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetX(
        init: CashbackController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 0,
              title: TranslatedText(
                "Cashback Offers",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.cashbackList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TranslatedText(controller.cashbackList[index].title ?? '',
                                      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? AppThemeData.grey50 : AppThemeData.grey900)),
                                ),
                                TranslatedText(
                                  controller.cashbackList[index].cashbackType == 'Percent'
                                      ? "${controller.cashbackList[index].cashbackAmount}%"
                                      : Constant.amountShow(amount: "${controller.cashbackList[index].cashbackAmount}"),
                                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? AppThemeData.grey50 : AppThemeData.grey900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TranslatedText(
                              "${"Min spent"} ${Constant.amountShow(amount: "${controller.cashbackList[index].minimumPurchaseAmount ?? 0.0}")} | ${"Valid till"} ${Constant.timestampToDateTime2(controller.cashbackList[index].endDate!)}",
                              style: TextStyle(color: isDark ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: 'Urbanist', fontSize: 14),
                            ),
                            TranslatedText(
                              "${"Maximum cashback up to"} ${Constant.amountShow(amount: "${controller.cashbackList[index].maximumDiscount ?? 0.0}")}",
                              style: TextStyle(color: isDark ? AppThemeData.primary200 : AppThemeData.primary300, fontFamily: 'Urbanist', fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }),
          );
        });
  }
}
