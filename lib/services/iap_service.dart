import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static Future<void> buyJokeCredits() async {
    final productDetails = await _iap.queryProductDetails({'buy_500_jokes'});
    if (productDetails.notFoundIDs.isEmpty) {
      final purchaseParam = PurchaseParam(productDetails: productDetails.productDetails.first);
      _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {

      print('Product not found.');
    }
  }

  static void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {

        print('Purchase successful! Add 500 credits.');
      }
    }
  }
}
