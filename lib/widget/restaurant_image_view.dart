import 'dart:async';

import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';

class RestaurantImageView extends StatefulWidget {
  final VendorModel vendorModel;
  final double? height;

  const RestaurantImageView({super.key, required this.vendorModel, this.height});

  @override
  State<RestaurantImageView> createState() => _RestaurantImageViewState();
}

class _RestaurantImageViewState extends State<RestaurantImageView> {
  int currentPage = 0;

  PageController pageController = PageController(initialPage: 1);

  @override
  void initState() {
    animateSlider();
    super.initState();
  }

  void animateSlider() {
    if (widget.vendorModel.photos != null && widget.vendorModel.photos!.isNotEmpty) {
      if (widget.vendorModel.photos!.length > 1) {
        Timer.periodic(const Duration(seconds: 2), (Timer timer) {
          if (currentPage < widget.vendorModel.photos!.length - 1) {
            currentPage++;
          } else {
            currentPage = 0;
          }

          if (pageController.hasClients) {
            pageController.animateToPage(
              currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? Responsive.height(20, context);
    return SizedBox(
      height: h,
      child: widget.vendorModel.photos == null || widget.vendorModel.photos!.isEmpty
          ? NetworkImageWidget(
              imageUrl: widget.vendorModel.photo.toString(),
              fit: BoxFit.cover,
              height: h,
              width: Responsive.width(100, context),
            )
          : PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: pageController,
              scrollDirection: Axis.horizontal,
              allowImplicitScrolling: true,
              itemCount: widget.vendorModel.photos!.length,
              padEnds: false,
              pageSnapping: true,
              itemBuilder: (BuildContext context, int index) {
                String image = widget.vendorModel.photos![index];
                return NetworkImageWidget(
                  imageUrl: image.toString(),
                  fit: BoxFit.cover,
                  height: h,
                  width: Responsive.width(100, context),
                );
              },
            ),
    );
  }
}
