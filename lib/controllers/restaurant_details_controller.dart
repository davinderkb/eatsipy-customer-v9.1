import 'dart:async';
import 'dart:developer';
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/models/AttributesModel.dart';
import 'package:eatsipy_customer/models/cart_product_model.dart';
import 'package:eatsipy_customer/models/coupon_model.dart';
import 'package:eatsipy_customer/models/favourite_item_model.dart';
import 'package:eatsipy_customer/models/favourite_model.dart';
import 'package:eatsipy_customer/models/product_model.dart';
import 'package:eatsipy_customer/models/vendor_category_model.dart';
import 'package:eatsipy_customer/models/vendor_model.dart';
import 'package:eatsipy_customer/services/cart_provider.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsController extends GetxController {
  Rx<TextEditingController> searchEditingController =
      TextEditingController().obs;

  RxBool isLoading = true.obs;
  RxBool isMenuLoading = true.obs;
  RxBool hasMenuLoadError = false.obs;
  RxBool showLongLoadingMessage = false.obs;
  RxString menuLoadingMessage = "Preparing the menu...".obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;

  RxBool isVag = false.obs;
  RxBool isNonVag = false.obs;
  RxBool isMenuOpen = false.obs;
  RxBool isSearchActive = false.obs;
  RxString searchQuery = ''.obs;

  final ScrollController menuScrollController = ScrollController();
  final FocusNode searchFocusNode = FocusNode();
  final GlobalKey searchSectionKey = GlobalKey();
  final Map<String, GlobalKey> categoryKeys = {};
  final Map<String, double> categoryScrollOffsets = {};
  RxInt activeCategoryIndex = 0.obs;
  RxBool hasScrolledMenu = false.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> allProductList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  RxList<MenuCategoryMeta> menuCategoryMetaList = <MenuCategoryMeta>[].obs;
  final List<MenuSearchEntry> _menuSearchIndex = <MenuSearchEntry>[];

  RxList<CouponModel> couponList = <CouponModel>[].obs;

  final List<String> _menuLoadingMessages = const [
    "Preparing the menu...",
    "Finding today’s best dishes...",
    "Loading fresh items for you...",
    "Getting offers and menu ready...",
  ];
  static const double _categoryScrollTopGap = 12;
  int _menuLoadingMessageIndex = 0;
  Timer? _menuLoadingMessageTimer;
  Timer? _longLoadingTimer;
  bool _hasRevealedSearchSession = false;

  @override
  void onInit() {
    // TODO: implement onInit
    menuScrollController.addListener(handleMenuScroll);
    searchFocusNode.addListener(() {
      isSearchActive.value =
          searchFocusNode.hasFocus || searchQuery.value.trim().isNotEmpty;
      if (searchFocusNode.hasFocus) {
        revealSearchResults(force: true);
      } else if (searchQuery.value.trim().isEmpty) {
        _hasRevealedSearchSession = false;
      }
    });
    getArgument();

    super.onInit();
  }

  void animateSlider() {
    if (vendorModel.value.photos != null &&
        vendorModel.value.photos!.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (currentPage < vendorModel.value.photos!.length - 1) {
          currentPage++;
        } else {
          currentPage.value = 0;
        }

        if (pageController.value.hasClients) {
          pageController.value.animateToPage(
            currentPage.value,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  final CartProvider cartProvider = CartProvider();

  Future<void> getArgument() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }
    isLoading.value = false;
    animateSlider();
    statusCheck();
    await loadMenuData();
    update();
  }

  Future<void> loadMenuData() async {
    isMenuLoading.value = true;
    hasMenuLoadError.value = false;
    showLongLoadingMessage.value = false;
    _startMenuLoadingTimers();

    try {
      await getProduct();
      await getFavouriteList();
    } catch (e, stack) {
      log("loadMenuData error :: $e", stackTrace: stack);
      hasMenuLoadError.value = true;
    } finally {
      isMenuLoading.value = false;
      _stopMenuLoadingTimers();
      update();
    }
  }

  Future<void> retryLoadMenu() async {
    allProductList.clear();
    productList.clear();
    vendorCategoryList.clear();
    couponList.clear();
    categoryKeys.clear();
    categoryScrollOffsets.clear();
    _menuSearchIndex.clear();
    searchQuery.value = '';
    searchEditingController.value.clear();
    await loadMenuData();
  }

  void _startMenuLoadingTimers() {
    _stopMenuLoadingTimers();
    _menuLoadingMessageIndex = 0;
    menuLoadingMessage.value = _menuLoadingMessages[_menuLoadingMessageIndex];
    _menuLoadingMessageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _menuLoadingMessageIndex =
          (_menuLoadingMessageIndex + 1) % _menuLoadingMessages.length;
      menuLoadingMessage.value = _menuLoadingMessages[_menuLoadingMessageIndex];
    });
    _longLoadingTimer = Timer(const Duration(seconds: 4), () {
      showLongLoadingMessage.value = true;
    });
  }

  void _stopMenuLoadingTimers() {
    _menuLoadingMessageTimer?.cancel();
    _menuLoadingMessageTimer = null;
    _longLoadingTimer?.cancel();
    _longLoadingTimer = null;
  }

  Future<void> getProduct() async {
    vendorCategoryList.clear();
    categoryKeys.clear();
    categoryScrollOffsets.clear();
    await FireStoreUtils.getProductByVendorId(vendorModel.value.id.toString())
        .then((value) {
      if ((Constant.isSubscriptionModelApplied == true ||
              Constant.adminCommission?.isEnabled == true) &&
          vendorModel.value.subscriptionPlan != null) {
        if (vendorModel.value.subscriptionPlan?.itemLimit == '-1') {
          allProductList.value = value;
          productList.value = value;
        } else {
          int selectedProduct = value.length <
                  int.parse(
                      vendorModel.value.subscriptionPlan?.itemLimit ?? '0')
              ? (value.isEmpty ? 0 : (value.length))
              : int.parse(vendorModel.value.subscriptionPlan?.itemLimit ?? '0');
          allProductList.value = value.sublist(0, selectedProduct);
          productList.value = value.sublist(0, selectedProduct);
        }
      } else {
        allProductList.value = value;
        productList.value = value;
      }
    });

    for (var element in productList) {
      await FireStoreUtils.getVendorCategoryById(element.categoryID.toString())
          .then(
        (value) {
          if (value != null) {
            vendorCategoryList.add(value);
          }
        },
      );
    }
    var seen = <String>{};
    vendorCategoryList.value = vendorCategoryList
        .where((element) => seen.add(element.id.toString()))
        .toList();

    for (var cat in vendorCategoryList) {
      categoryKeys[cat.id.toString()] = GlobalKey();
    }
    _buildMenuSearchIndex();
    buildMenuCategoryMetadata();
  }

  @override
  void onClose() {
    _stopMenuLoadingTimers();
    menuScrollController.dispose();
    searchFocusNode.dispose();
    searchEditingController.value.dispose();
    super.onClose();
  }

  void scrollToCategory(int index) {
    if (index >= menuCategoryMetaList.length) return;
    activeCategoryIndex.value = index;
    final key = categoryKeys[menuCategoryMetaList[index].categoryId];
    final context = key?.currentContext;
    if (context == null || !menuScrollController.hasClients) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;

    final mediaQuery = MediaQuery.maybeOf(context);
    final appBarBottom =
        (mediaQuery?.padding.top ?? 0) + kToolbarHeight + _categoryScrollTopGap;
    final sectionTop = renderObject.localToGlobal(Offset.zero).dy;
    final targetOffset =
        (menuScrollController.offset + sectionTop - appBarBottom).clamp(
      menuScrollController.position.minScrollExtent,
      menuScrollController.position.maxScrollExtent,
    );

    menuScrollController.animateTo(
      targetOffset.toDouble(),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void handleMenuScroll() {
    if (!menuScrollController.hasClients) return;
    if (!hasScrolledMenu.value && menuScrollController.offset > 40) {
      hasScrolledMenu.value = true;
    }
    updateActiveCategoryFromVisibility();
  }

  void updateActiveCategoryFromVisibility() {
    if (menuCategoryMetaList.isEmpty) return;
    var bestIndex =
        activeCategoryIndex.value.clamp(0, menuCategoryMetaList.length - 1);
    var bestDistance = double.infinity;
    for (var i = 0; i < menuCategoryMetaList.length; i++) {
      final key = categoryKeys[menuCategoryMetaList[i].categoryId];
      final context = key?.currentContext;
      if (context == null) continue;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) continue;
      final offset = renderObject.localToGlobal(Offset.zero).dy;
      categoryScrollOffsets[menuCategoryMetaList[i].categoryId] = offset;
      final distance = (offset - 170).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    if (activeCategoryIndex.value != bestIndex) {
      activeCategoryIndex.value = bestIndex;
    }
  }

  void buildMenuCategoryMetadata() {
    final metadata = <MenuCategoryMeta>[];
    for (final category in vendorCategoryList) {
      final categoryId = category.id.toString();
      final itemCount = productList
          .where((product) => product.categoryID == categoryId)
          .length;
      if (itemCount == 0) continue;
      metadata.add(
        MenuCategoryMeta(
          categoryId: categoryId,
          categoryName: category.title.toString(),
          itemCount: itemCount,
          scrollOffset: categoryScrollOffsets[categoryId],
        ),
      );
    }
    menuCategoryMetaList.value = metadata;
    if (activeCategoryIndex.value >= metadata.length) {
      activeCategoryIndex.value = metadata.isEmpty ? 0 : metadata.length - 1;
    }
  }

  void searchProduct(String name) {
    final wasSearchActive = isSearchActive.value;
    searchQuery.value = name;
    isSearchActive.value =
        searchFocusNode.hasFocus || searchQuery.value.trim().isNotEmpty;
    _applyVisibleMenuFilters();
    if (!wasSearchActive && isSearchActive.value) {
      revealSearchResults(force: true);
    }
  }

  void filterRecord() {
    _applyVisibleMenuFilters();
  }

  void clearMenuSearch() {
    searchEditingController.value.clear();
    searchQuery.value = '';
    isSearchActive.value = searchFocusNode.hasFocus;
    _applyVisibleMenuFilters();
    if (searchFocusNode.hasFocus) {
      revealSearchResults(force: true);
    }
  }

  void revealSearchResults({bool force = false}) {
    if (_hasRevealedSearchSession && !force) return;
    _hasRevealedSearchSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = searchSectionKey.currentContext;
      if (context == null || !menuScrollController.hasClients) return;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) return;

      final mediaQuery = MediaQuery.maybeOf(context);
      final appBarBottom = (mediaQuery?.padding.top ?? 0) + kToolbarHeight + 24;
      final sectionTop = renderObject.localToGlobal(Offset.zero).dy;
      if (sectionTop >= appBarBottom && sectionTop <= appBarBottom + 56) {
        return;
      }
      final targetOffset =
          (menuScrollController.offset + sectionTop - appBarBottom).clamp(
        menuScrollController.position.minScrollExtent,
        menuScrollController.position.maxScrollExtent,
      );

      menuScrollController.animateTo(
        targetOffset.toDouble(),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _applyVisibleMenuFilters() {
    final query = _normalizeSearchText(searchQuery.value);
    Iterable<ProductModel> filtered;
    if (query.isEmpty) {
      filtered = allProductList;
    } else {
      filtered = _searchProducts(query);
    }

    if (isVag.value == true && isNonVag.value == false) {
      filtered = filtered.where((product) => product.nonveg == false);
    } else if (isVag.value == false && isNonVag.value == true) {
      filtered = filtered.where((product) => product.nonveg == true);
    }

    productList.value = filtered.toList();
    buildMenuCategoryMetadata();
    update();
  }

  List<ProductModel> _searchProducts(String query) {
    final scored = <({ProductModel product, int score})>[];
    for (final entry in _menuSearchIndex) {
      var score = 0;
      if (entry.normalizedName.startsWith(query)) {
        score = 400;
      } else if (entry.normalizedName.contains(query)) {
        score = 300;
      } else if (entry.normalizedCategory.contains(query)) {
        score = 200;
      } else if (entry.normalizedDescription.contains(query) ||
          entry.normalizedDietTag.contains(query)) {
        score = 100;
      }
      if (score > 0) {
        scored.add((product: entry.product, score: score));
      }
    }
    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return (a.product.name ?? '').compareTo(b.product.name ?? '');
    });
    return scored.map((entry) => entry.product).toList();
  }

  void _buildMenuSearchIndex() {
    final categoryNames = {
      for (final category in vendorCategoryList)
        category.id.toString(): category.title.toString(),
    };
    _menuSearchIndex
      ..clear()
      ..addAll(allProductList.map((product) {
        final categoryName = categoryNames[product.categoryID] ?? '';
        return MenuSearchEntry(
          product: product,
          normalizedName: _normalizeSearchText(product.name ?? ''),
          normalizedDescription:
              _normalizeSearchText(product.description ?? ''),
          normalizedCategory: _normalizeSearchText(categoryName),
          normalizedDietTag: product.nonveg == true ? 'non veg nonveg' : 'veg',
        );
      }));
  }

  String _normalizeSearchText(String value) {
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<List<ProductModel>> getProductByCategory(
      VendorCategoryModel vendorCategoryModel) async {
    return productList
        .where((p0) => p0.categoryID == vendorCategoryModel.id)
        .toList();
  }

  Future<void> getFavouriteList() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );

      await FireStoreUtils.getFavouriteItem().then(
        (value) {
          favouriteItemList.value = value;
        },
      );

      await FireStoreUtils.getOfferByVendorId(vendorModel.value.id.toString())
          .then(
        (value) {
          couponList.value = value;
        },
      );
    }
    await getAttributeData();
    update();
  }

  RxBool isOpen = false.obs;

  String get todayTimingDisplay {
    final now = DateTime.now();
    final day = DateFormat('EEEE', 'en_US').format(now);
    for (var wh in vendorModel.value.workingHours ?? []) {
      if (wh.day == day && wh.timeslot != null && wh.timeslot!.isNotEmpty) {
        final from = wh.timeslot!.first.from ?? '';
        final to = wh.timeslot!.last.to ?? '';
        return '$from – $to';
      }
    }
    return '';
  }

  void statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in vendorModel.value.workingHours ?? []) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              isOpen.value = true;
            }
          }
        }
      }
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList selectedVariants = [].obs;
  RxList selectedIndexVariants = [].obs;
  RxList selectedIndexArray = [].obs;

  RxList selectedAddOns = [].obs;

  RxInt quantity = 1.obs;

  String calculatePrice(ProductModel productModel) {
    String mainPrice = "0";
    String variantPrice = "0";
    String adOnsPrice = "0";

    if (productModel.itemAttribute != null) {
      if (productModel.itemAttribute!.variants!
          .where((element) => element.variantSku == selectedVariants.join('-'))
          .isNotEmpty) {
        variantPrice = Constant.productCommissionPrice(
            vendorModel.value,
            productModel.itemAttribute!.variants!
                    .where((element) =>
                        element.variantSku == selectedVariants.join('-'))
                    .first
                    .variantPrice ??
                '0');
      }
    } else {
      String price = Constant.productCommissionPrice(
          vendorModel.value, productModel.price.toString());
      String disPrice = double.parse(productModel.disPrice.toString()) <= 0
          ? "0"
          : Constant.productCommissionPrice(
              vendorModel.value, productModel.disPrice.toString());
      if (double.parse(disPrice) <= 0) {
        variantPrice = price;
      } else {
        variantPrice = disPrice;
      }
    }

    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true) {
        adOnsPrice = (double.parse(adOnsPrice.toString()) +
                double.parse(Constant.productCommissionPrice(vendorModel.value,
                    productModel.addOnsPrice![i].toString())))
            .toString();
      }
    }
    adOnsPrice = (quantity.value * double.parse(adOnsPrice)).toString();
    mainPrice = ((double.parse(variantPrice.toString()) *
                double.parse(quantity.value.toString())) +
            double.parse(adOnsPrice.toString()))
        .toString();
    return mainPrice;
  }

  Future<void> getAttributeData() async {
    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
      }
    });
  }

  Future<void> addToCart({
    required ProductModel productModel,
    required String price,
    required String discountPrice,
    required bool isIncrement,
    required int quantity,
    VariantInfo? variantInfo,
  }) async {
    CartProductModel cartProductModel = CartProductModel();

    String adOnsPrice = "0";
    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true &&
          productModel.addOnsPrice![i] != '0') {
        adOnsPrice = (double.parse(adOnsPrice.toString()) +
                double.parse(Constant.productCommissionPrice(vendorModel.value,
                    productModel.addOnsPrice![i].toString())))
            .toString();
      }
    }

    if (variantInfo != null) {
      cartProductModel.id =
          "${productModel.id!}~${variantInfo.variantId.toString()}";
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = variantInfo;
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
      cartProductModel.taxSetting = Constant.taxScope == "order"
          ? []
          : Constant.taxProductList
              ?.where((activeTax) =>
                  productModel.taxSetting
                      ?.any((productTax) => productTax.id == activeTax.id) ??
                  false)
              .toList();
    } else {
      cartProductModel.id = productModel.id!;
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = VariantInfo();
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
      cartProductModel.taxSetting = Constant.taxScope == "order"
          ? []
          : Constant.taxProductList
              ?.where((activeTax) =>
                  productModel.taxSetting
                      ?.any((productTax) => productTax.id == activeTax.id) ??
                  false)
              .toList();
    }

    if (isIncrement) {
      await cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      await cartProvider.removeFromCart(cartProductModel, quantity);
    }
    log("===> new ${cartItem.length}");
    update();
  }
}

class MenuCategoryMeta {
  final String categoryId;
  final String categoryName;
  final int itemCount;
  final double? scrollOffset;

  const MenuCategoryMeta({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    this.scrollOffset,
  });
}

class MenuSearchEntry {
  final ProductModel product;
  final String normalizedName;
  final String normalizedDescription;
  final String normalizedCategory;
  final String normalizedDietTag;

  const MenuSearchEntry({
    required this.product,
    required this.normalizedName,
    required this.normalizedDescription,
    required this.normalizedCategory,
    required this.normalizedDietTag,
  });
}
