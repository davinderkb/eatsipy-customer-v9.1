import 'dart:io';
import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/controllers/map_view_controller.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/themes/responsive.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:eatsipy_customer/utils/network_image_widget.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return GetX(
      init: MapViewController(),
      builder: (controller) {
        return Stack(
          children: [
            Constant.selectedMapType == "osm"
                ? flutterMap.FlutterMap(
                    mapController: controller.osmMapController,
                    options: flutterMap.MapOptions(
                      initialCenter: location.LatLng(Constant.selectedLocation.location!.latitude ?? 0.0, Constant.selectedLocation.location!.longitude ?? 0.0),
                      initialZoom: 10,
                    ),
                    children: [
                      flutterMap.TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: Platform.isAndroid ? 'com.eatsipy.customer.android' : 'com.eatsipy.customer.ios',
                      ),
                      flutterMap.MarkerLayer(
                        markers: controller.osmMarker,
                      ),
                    ],
                  )
                : GoogleMap(
                    mapType: MapType.terrain,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    markers: Set<Marker>.of(controller.markers.values),
                    onMapCreated: (GoogleMapController mapController) {
                      controller.mapController = mapController;
                    },
                    mapToolbarEnabled: true,
                    initialCameraPosition: CameraPosition(
                      zoom: 18,
                      target: controller.homeController.allNearestRestaurant.isEmpty
                          ? LatLng(
                              Constant.selectedLocation.location!.latitude ?? 45.521563,
                              Constant.selectedLocation.location!.longitude ?? -122.677433,
                            )
                          : LatLng(
                              controller.homeController.allNearestRestaurant.first.latitude ?? 45.521563,
                              controller.homeController.allNearestRestaurant.first.longitude ?? -122.677433,
                            ),
                    ),
                  ),
            controller.homeController.allNearestRestaurant.isEmpty
                ? Container()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: SizedBox(
                        height: Responsive.height(25, context),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: PageView.builder(
                                pageSnapping: true,
                                controller: PageController(viewportFraction: 0.88),
                                onPageChanged: (value) async {
                                  if (Constant.selectedMapType == "osm") {
                                    controller.osmMapController.move(
                                        location.LatLng(
                                          controller.homeController.allNearestRestaurant[value].latitude!,
                                          controller.homeController.allNearestRestaurant[value].longitude!,
                                        ),
                                        16);
                                  } else {
                                    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
                                      zoom: 15,
                                      target: LatLng(
                                        controller.homeController.allNearestRestaurant[value].latitude!,
                                        controller.homeController.allNearestRestaurant[value].longitude!,
                                      ),
                                    ));
                                    controller.mapController!.animateCamera(cameraUpdate);
                                  }
                                },
                                itemCount: controller.homeController.allNearestRestaurant.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  VendorModel vendorModel = controller.homeController.allNearestRestaurant[index];
                                  bool isOpen = Constant.statusCheckOpenORClose(vendorModel: vendorModel);
                                  return InkWell(
                                    onTap: () {
                                      Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel})?.then((v) {
                                        controller.homeController.getFavouriteRestaurant();
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: index == 0 ? 0 : 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                  child: Stack(
                                                    children: [
                                                      NetworkImageWidget(
                                                        imageUrl: vendorModel.photo.toString(),
                                                        fit: BoxFit.cover,
                                                        height: Responsive.height(14, context),
                                                        width: Responsive.width(100, context),
                                                      ),
                                                      Container(
                                                        height: Responsive.height(14, context),
                                                        width: Responsive.width(100, context),
                                                        decoration: BoxDecoration(
                                                          color: (isOpen) ? null : Colors.black38,
                                                          gradient: (isOpen)
                                                              ? LinearGradient(
                                                                  begin: const Alignment(-0.00, -1.00),
                                                                  end: const Alignment(0, 1),
                                                                  colors: [Colors.black.withValues(alpha: 0), AppThemeData.grey900],
                                                                )
                                                              : null,
                                                        ),
                                                        child: (isOpen)
                                                            ? SizedBox()
                                                            : Center(
                                                                child: Image.asset(
                                                                "assets/images/closed.PNG",
                                                                height: Responsive.height(16, context),
                                                                fit: BoxFit.fill,
                                                              )),
                                                      ),
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            if (controller.homeController.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty) {
                                                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                                              controller.homeController.favouriteList.removeWhere((item) => item.restaurantId == vendorModel.id);
                                                              await FireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                                                            } else {
                                                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: FireStoreUtils.getCurrentUid());
                                                              controller.homeController.favouriteList.add(favouriteModel);
                                                              await FireStoreUtils.setFavouriteRestaurant(favouriteModel);
                                                            }
                                                          },
                                                          child: Obx(
                                                            () => controller.homeController.favouriteList.where((p0) => p0.restaurantId == vendorModel.id).isNotEmpty
                                                                ? SvgPicture.asset(
                                                                    "assets/icons/ic_like_fill.svg",
                                                                  )
                                                                : SvgPicture.asset(
                                                                    "assets/icons/ic_like.svg",
                                                                  ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: Offset(Responsive.width(isRTL == true ? 3 : -3, context), Responsive.height(11, context)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Visibility(
                                                        visible: (vendorModel.isSelfDelivery == true && Constant.isSelfDeliveryFeature == true),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                                              decoration: BoxDecoration(
                                                                color: AppThemeData.lightGreen,
                                                                borderRadius: BorderRadius.circular(120), // Optional
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    "assets/icons/ic_free_delivery.svg",
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  TranslatedText(
                                                                    "Free Delivery",
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: AppThemeData.darkGreen,
                                                                      fontFamily: 'Urbanist',
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: ShapeDecoration(
                                                          color: isDark ? AppThemeData.primary600 : AppThemeData.primary50,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_star.svg",
                                                                colorFilter: ColorFilter.mode(AppThemeData.primary300, BlendMode.srcIn),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                                                style: TextStyle(
                                                                    color: isDark ? AppThemeData.primary300 : AppThemeData.primary300,
                                                                    fontFamily: 'Urbanist',
                                                                    fontWeight: FontWeight.w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        decoration: ShapeDecoration(
                                                          color: isDark ? AppThemeData.secondary600 : AppThemeData.secondary50,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_map_distance.svg",
                                                                colorFilter: const ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              TranslatedText(
                                                                "${Constant.getDistance(
                                                                  lat1: vendorModel.latitude.toString(),
                                                                  lng1: vendorModel.longitude.toString(),
                                                                  lat2: Constant.selectedLocation.location!.latitude.toString(),
                                                                  lng2: Constant.selectedLocation.location!.longitude.toString(),
                                                                )} ${Constant.distanceType}",
                                                                style: TextStyle(
                                                                    color: isDark ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                                    fontFamily: 'Urbanist',
                                                                    fontWeight: FontWeight.w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TranslatedText(
                                                    vendorModel.title.toString(),
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                                                      color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                                                    ),
                                                  ),
                                                  TranslatedText(
                                                    vendorModel.location.toString(),
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      overflow: TextOverflow.ellipsis,
                                                      fontFamily: 'Urbanist',
                                                      fontWeight: FontWeight.w500,
                                                      color: isDark ? AppThemeData.grey400 : AppThemeData.grey400,
                                                    ),
                                                  ),
                                                  (isOpen == false)
                                                      ? Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TranslatedText(
                                                              Constant.getNextOpeningTime(vendorModel, DateTime.now()),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(color: AppThemeData.danger300, fontFamily: 'Urbanist', fontWeight: FontWeight.w500),
                                                            )
                                                          ],
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
