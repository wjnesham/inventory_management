import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pantryfox/model/upcJson.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/services/firestore.dart';
import 'package:pantryfox/singleton.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:core';

class UpcHttpController {
  static const GOOD_RESPONSE = 200;
  static const REDIRECTION = 300;
  static const CLIENT_ERROR = 400;
  static const SERVER_ERROR = 500;

//  var apiKeyToken = "/8512882268C5BD916F5B9BB664367EB3";

  var url = "https://api.upcitemdb.com/prod/trial/lookup?upc=";

  //from site https://www.upcitemdb.com/api/explorer#!/lookup/get_trial_lookup
  //NEW https://api.upcitemdb.com/prod/trial/lookup?upc=0885909950805

  //corn 0041498115005
  Future<Upc> getFutureUpcData(String upcId) async {
//    if (upcId.length > 12) {
//      upcId = upcId.substring(upcId.length - 12);
//    }

    // Building work for all barcodes?
    String fullUrl = url + upcId;
    debugPrint(fullUrl);
    http.Response response;
    try {
      final client = new HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      client.getUrl(Uri.parse(fullUrl));
      try {
        response = await http.get(fullUrl);
      } catch (e) {
        debugPrint(e);
      }
      // Check response status code.
      if (response.statusCode >= GOOD_RESPONSE && response.statusCode < REDIRECTION) {
        // Good response.
        // handle data
        Upc goodResponseUpc = getUpcOnGoodResponse(response.body);
        if (goodResponseUpc.items.isEmpty) {
          debugPrint('Not good. Try EAN or something.');
        }
        return goodResponseUpc;
      } else {
        // Something bad happened.
        if (response.statusCode >= SERVER_ERROR) {
          //popup error and say try again later - probably toast
          debugPrint('No Upc because of Server Error');
        } else if (response.statusCode >= CLIENT_ERROR) {
          debugPrint('UPC not found: Client Error');
        } else {
          debugPrint('UPC not found: Lost in Redirection');
        }
        debugPrint('Error creating upc in getFutureUpcData. Returning null.');

        /// Check for this
//      return new Upc();
//        getFutureUpcData(upcId)
        return null;
      }
    } on TimeoutException catch (_) {
      // A timeout occurred.
      debugPrint('Timeout occured');
      return null;
    } on SocketException catch (_) {
      // Other exception
      debugPrint('Socket Exception occured');
      return null;
    }
  }

  Upc getUpcOnGoodResponse(String body) {
    // If the call to the server was successful, parse the JSON
    var upcJson = json.decode(body); // Getting stuck here.
    Upc upcthing = Upc.fromJson(upcJson);
    if (upcthing == null) {
      debugPrint('Maybe it was NOT a good response!');
    }

    return upcthing;
  }

  /// Await a response.
  Future<void> updatePersnicketyServer() async {
    FireStoreService service = Singleton.instance.firebaseService;
    await service.backupUpcDataToFirebase();
  }

  Future<void> fetchPersnicketyData() async {
    FireStoreService service = Singleton.instance.firebaseService;
    await service.restoreUpcDataFromFirestore();
  }

  ///Sync between SQLFlite and Firestore
  Future<void> syncData() async {
    FireStoreService service = Singleton.instance.firebaseService;
    await service.syncData();
  }

  // Get data from db

  ///If returns null then use noImage
  Future<String> getWorkingImageUrl(Upc upc) async {
    if (upc == null || upc.items.isEmpty) {
      debugPrint('No items, so no images.');
      return null;
    }
    if (upc.items[0].images == null || upc.items[0].images.isEmpty) {
      debugPrint('No images 1');
      return null;
    }

    List<String> images = upc.items[0].images;
    for (int i = 0; i < images.length; i++) {
      var url = await checkImage(images[i]);
      if (url != null) {
        return images[i];
      }
      if (i > 1) break;
    }
    debugPrint('No images 2');
    return null;
  }

  Future<String> checkImage(String imgUrl) async {
    try {
      final response = await http.get(imgUrl);
      if (response.statusCode >= GOOD_RESPONSE && response.statusCode < CLIENT_ERROR) {
        debugPrint("header keys: " + response.headers.keys.toString());
        if (response.headers.containsKey("content-type")) {
          String contentType = response.headers["content-type"];
          debugPrint("Content-type = " + contentType);
          // We got a good response, but is our image good?
          if (contentType.toLowerCase().contains("jpg") ||
              contentType.toLowerCase().contains("png") ||
              contentType.toLowerCase().contains("image")) {
            return imgUrl;
          }
        }
      }
    } on Exception {
      debugPrint("checkImage: Image not found $imgUrl");
      return null;
    }
    debugPrint("checkImage: Image not found $imgUrl");
    return null;
  }

  ///Given a Upc from json, return the DB version
  getUpcDb(Upc upc) {
    if (upc == null) return null;

    UpcDb upcDb = new UpcDb(code: upc.code);
    if (upc.items != null && upc.items.isNotEmpty) {
      Item item = upc.items[0];
      upcDb.code = item.upc;
      upcDb.total = 1; //represents itself, it will be added to total later
      upcDb.title = item.title ?? '';
      upcDb.description = item.description ?? '';
      upcDb.brand = item.brand ?? '';
      upcDb.model = item.model ?? '';
      upcDb.price = getPrice(upc);
      upcDb.weight = item.weight ?? '';
      if (item.images.isNotEmpty) {
        getWorkingImageUrl(upc).then((value) => {upcDb.imageLink = value});
      } else {
        upcDb.imageLink = 'https://uae.microless.com/cdn/no_image.jpg';
      }
      // Only stored as upcDb or upcDto, so this should only be set when scanning
    }
    if (upcDb.code == null || upcDb.title == null) {
      debugPrint('Check getUpcDb for error.');
    }

    return upcDb;
  }

  void debugDumpScan(Upc upc) {
    int itemIndex = 0;
    if (upc == null || upc.items.isEmpty || upc.items is String) {
      debugPrint('No items found in Upc 1.');
      return;
    } else {
      debugPrint('debugDumpScan was called with something.');
    }
    if (upc.items[itemIndex] == null || upc.items[itemIndex] is String) {
      debugPrint('No items found in Upc 2.');
      return;
    }
    double offerPrice = upc.items[0].offers[0] ?? 0.420;

    double listPrice = upc.items[0].offers[0].listPrice ?? 0.420;
    for (var item in upc.items) {
      debugPrint('/////////');
      debugPrint('Item Index: ' + itemIndex.toString());
      debugPrint('EAN: ' + item.ean);
      debugPrint('ASIN: ' + item.asin);
      debugPrint('GTIN: ' + item.gtin);
      debugPrint("Item: ${item.title}");
      debugPrint("Upc: ${item.upc}");
      debugPrint("Description: ${item.description}");
      debugPrint('Price High: \$' + item.highestRecordedPrice.toDouble().toString());
      debugPrint('Price Low: \$' + item.lowestRecordedPrice.toDouble().toString());
      debugPrint('Offer Price: \$' + offerPrice.toString());
      debugPrint('List Price (*May be buggy): \$' + listPrice.toString());
      debugPrint('/////////');
      itemIndex++;
    }
  }

  String getPrice(Upc upc) {
    if (upc.items.isEmpty || upc.items == null) {
      return "0.0";
    }
    if (upc.items[0].offers == null || upc.items[0].offers.isEmpty) {
      debugPrint('getPrice. Error?');
      if (upc.items[0].lowestRecordedPrice == null || upc.items[0].highestRecordedPrice == null) {
        return "0.0";
      }
      if (upc.items[0].lowestRecordedPrice > 0) {
        return upc.items[0].lowestRecordedPrice.toString();
      } else if (upc.items[0].highestRecordedPrice > 0) {
        return upc.items[0].highestRecordedPrice.toString();
      } else {
        return "0.0";
      }
    }
    if (upc.items[0].offers[0].price == null || upc.items[0].offers[0].price == 0.0) {
      if (upc.items[0].offers[0].listPrice == null) {
        return "0.0";
      } else {
        return upc.items[0].offers[0].listPrice.toString();
      }
    } else {
      return upc.items[0].offers[0].price.toString();
    }
  } // Tries to return a price greater than 0.0

} //End class

class SetUpJson {
//  String optionID;
  Map<String, dynamic> data;
//  String data;
  SetUpJson(this.data);
  Map<String, dynamic> toJsonData() {
    var map = new Map<String, dynamic>();
//    map["optionID"] = optionID;
    map["data"] = data;

    return map;
  }
}
