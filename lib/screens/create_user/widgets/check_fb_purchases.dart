import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pantryfox/helper/userUtils.dart';

const bool kAutoConsume = true;
const List<String> _kProductIds = ["FirebaseSubscription"];

class FirebasePurchases {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  Card buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = Container(
        color: myColorArray[0],
        child: ListTile(
          onTap: () => _connection.buyNonConsumable(purchaseParam: null),
          leading: Icon(_isAvailable ? Icons.check : Icons.block,
              color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
          title: Text('The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
        ));
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected', style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //TODO: Create an event for -> showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //TODO: Create an event for -> handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          //TODO: Create an event for -> bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          // deliverProduct(purchaseDetails);
          // } else {
          //TODO: Create an event for ->   _handleInvalidPurchase(purchaseDetails);
          //   return;
          // }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }
}
