import 'package:eatsipy_customer/app/home_screen/story_view.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/home_controller.dart';
import 'package:eatsipy_customer/models/story_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoryView extends StatelessWidget {
  final HomeController controller;

  const StoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.storyList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          StoryModel storyModel = controller.storyList[index];
          return Padding(
            key: ValueKey(storyModel.vendorID),
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MoreStories(
                          storyList: controller.storyList,
                          index: index,
                        )));
              },
              child: SizedBox(
                width: 134,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Stack(
                    children: [
                      NetworkImageWidget(
                        imageUrl: storyModel.videoThumbnail.toString(),
                        fit: BoxFit.cover,
                        height: Responsive.height(100, context),
                        width: Responsive.width(100, context),
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.30),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                        child: FutureBuilder(
                            future: FireStoreUtils.getVendorById(storyModel.vendorID.toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Constant.loader();
                              } else {
                                if (snapshot.hasError) {
                                  return Center(child: TranslatedText('Error: ${snapshot.error}'));
                                } else if (snapshot.data == null) {
                                  return const SizedBox();
                                } else {
                                  VendorModel vendorModel = snapshot.data!;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipOval(
                                        child: NetworkImageWidget(
                                          imageUrl: vendorModel.photo.toString(),
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TranslatedText(
                                              vendorModel.title.toString(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset("assets/icons/ic_star.svg"),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum!.toStringAsFixed(0))} reviews",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: AppThemeData.warning300,
                                                    fontSize: 10,
                                                    overflow: TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
