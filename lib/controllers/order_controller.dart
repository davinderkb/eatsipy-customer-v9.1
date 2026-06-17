import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:eatsipy_customer/constant/constant.dart';
import 'package:eatsipy_customer/models/cart_product_model.dart';
import 'package:eatsipy_customer/models/order_model.dart';
import 'package:eatsipy_customer/services/cart_provider.dart';
import 'package:eatsipy_customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  RxList<OrderModel> allList = <OrderModel>[].obs;
  RxList<OrderModel> inProgressList = <OrderModel>[].obs;
  RxList<OrderModel> deliveredList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledList = <OrderModel>[].obs;

  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  DocumentSnapshot? _lastDocument;

  @override
  void onInit() {
    super.onInit();
    getOrder();
  }

  void _updateFilteredLists() {
    rejectedList.value = allList.where((p0) => p0.status == Constant.orderRejected).toList();
    inProgressList.value =
        allList.where((p0) => p0.status == Constant.orderAccepted || p0.status == Constant.driverPending || p0.status == Constant.orderShipped || p0.status == Constant.orderInTransit).toList();
    deliveredList.value = allList.where((p0) => p0.status == Constant.orderCompleted).toList();
    cancelledList.value = allList.where((p0) => p0.status == Constant.orderCancelled).toList();
  }

  Future<void> getOrder() async {
    if (Constant.userModel != null) {
      isLoading.value = true;
      _lastDocument = null;
      hasMore.value = true;
      final result = await FireStoreUtils.getOrdersPaginated(limit: 20);
      allList.value = result.orders;
      _lastDocument = result.lastDoc;
      hasMore.value = result.orders.length == 20;
      _updateFilteredLists();
    }
    isLoading.value = false;
  }

  Future<void> loadMoreOrders() async {
    if (!hasMore.value || isLoadingMore.value || _lastDocument == null) return;
    isLoadingMore.value = true;
    final result = await FireStoreUtils.getOrdersPaginated(limit: 20, startAfter: _lastDocument);
    allList.addAll(result.orders);
    _lastDocument = result.lastDoc;
    hasMore.value = result.orders.length == 20;
    _updateFilteredLists();
    isLoadingMore.value = false;
  }

  final CartProvider cartProvider = CartProvider();

  void addToCart({required CartProductModel cartProductModel}) {
    cartProvider.addToCart(Get.context!, cartProductModel, cartProductModel.quantity!);
    update();
  }

  Future<bool> hasAnyPublishedProduct(List<CartProductModel>? products) async {
    if (products == null || products.isEmpty) return false;
    for (final item in products) {
      final product = await FireStoreUtils.getProductById(item.id ?? '');
      if (product == null || product.publish == false) {
        return false;
      }
    }
    return true;
  }
}
