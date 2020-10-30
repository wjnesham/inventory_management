import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';
import 'package:pantryfox/screens/ads/widgets/test_device.dart';

Container getBannerAd(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
    decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor)),
    child: getAd(DFPAdSize.BANNER),
  );
}

Container getBottomBannerAd(BuildContext context) {
  return
      // Expanded(
      //   child: Align(
      //     alignment: FractionalOffset.bottomCenter,
      //     child:
      Container(
    margin: EdgeInsets.symmetric(vertical: 16.0),
    decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor)),
    child: getAd(DFPAdSize.BANNER),
  );
}

DFPBanner getAd(DFPAdSize size) {
  return DFPBanner(
    isDevelop: true,
    testDevices: MyTestDevices(),
    adUnitId: '/XXXXXXXXX/XXXXXXXXX',
    adSize: size,
    onAdLoaded: () {
      print('Banner onAdLoaded');
    },
    onAdFailedToLoad: (errorCode) {
      print('Banner onAdFailedToLoad: errorCode:$errorCode');
    },
    onAdOpened: () {
      print('Banner onAdOpened');
    },
    onAdClosed: () {
      print('Banner onAdClosed');
    },
    onAdLeftApplication: () {
      print('Banner onAdLeftApplication');
    },
  );
}
