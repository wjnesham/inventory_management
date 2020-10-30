
import 'dart:core';

///This class works with the json only. The one that works with SQLFlite is UpcDb found
///in upc_database.dart. Keep these separate. The json version is likely to stay longer but
///the upc_database.dart version may be replaced by firebase.
class Upc {

  String code;
  num total;
  num offset;
  List<Item> items;

  Upc({this.code, this.total, this.offset, this.items});

  static const String codeName = 'code';
  static const String totalName = 'total';
  static const String offsetName = 'offset';
  static const String itemsName = 'items';


  factory Upc.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to Upc");
    }

    List <Item> itemList;

    var list = json['items'] as List; //list of dynamic
    if (list == null) {
      itemList = new List();
    } else {
      itemList = list.map((i) => Item.fromJson(i)).toList();
    }

    num tempTotal, tempOffset;
    if (json [totalName] is num) {
      tempTotal = json [totalName];
    }
    if (json [offsetName] is num) {
      tempOffset = json [offsetName];
    }
    return Upc(
        code: json [codeName] == null ? "" : json [codeName],
        total: tempTotal == null ? 0 : tempTotal,
        offset: tempOffset == null ? 0 : tempOffset,
        items: itemList == null ? new List() : itemList
    );
  }
}



class Item {
  String ean;
  String title;
  String upc;
  String gtin; //GTIN describes family of UPC and EAN global data structures.
  String asin; //Amazon Standard Identification Number: a 10-character
  String description;
  String brand;
  String model;
  String dimension;
  String weight;
  String currency;
  num lowestRecordedPrice;
  num highestRecordedPrice;
  List<String> images;
  List<Offer> offers;

  Item({this.ean, this.title, this.upc,
    this.gtin, this.asin, this.description,
    this.brand, this.model, this.dimension,
    this.weight, this.currency, this.lowestRecordedPrice,
    this.highestRecordedPrice, this.images, this.offers
  });

  factory Item.fromJson(Map<String, dynamic> json){
    if (json == null) {
      throw FormatException("Null JSON provided to Item");
    }

    List <Offer> offerList;
    List <String> imageList;

    var dynamicImagesList = json['images'] as List;
    if (dynamicImagesList == null) {
      imageList = new List();
      print('No image found in dynamic list.');
      imageList.add('https://uae.microless.com/cdn/no_image.jpg');
    } else { //fromJson sorta
      print('An image was found in dynamic list.');
      imageList = new List<String>.from(dynamicImagesList);
      if(imageList.isEmpty) { //No images
        imageList.add('https://uae.microless.com/cdn/no_image.jpg');
      }
    }

    if(imageList.isNotEmpty) print(imageList.first);
    else print('Image error!');

    var dynamicOffersList = json['offers'] as List;

    if (dynamicOffersList == null) {
      offerList = new List();
    } else {
      offerList = dynamicOffersList.map((i) => Offer.fromJson(i)).toList();
    }

    num tempLowestPrice;
    num tempHighestPrice;
    if (json ['lowest_recorded_price'] is num) {
      tempLowestPrice = json ['lowest_recorded_price'];
    }
    if (json ['highest_recorded_price'] is num) {
      tempHighestPrice = json ['highest_recorded_price'];
    }
    return Item(
        ean: json ['ean'],
        title: json ['title'],
        upc: json ['upc'],
        gtin: json ['gtin'],
        asin: json ['asin'],
        description: json ['description'],
        brand: json ['brand'],
        model: json ['model'],
        dimension: json ['dimension'],
        weight: json ['weight'],
        currency: json ['currency'],
        lowestRecordedPrice: tempLowestPrice == null ? 0.0 : tempLowestPrice,
        highestRecordedPrice: tempHighestPrice == null ? 0.0 : tempHighestPrice,
        images: imageList == null ? new List() : imageList,
        offers: offerList == null ? new List() : offerList
    );
  }
}

class Offer {
  String merchant;
  String domain;
  String title;
  String currency;
  num listPrice;
  num price;
  String shipping;
  String condition;
  String availability;
  String link;
  num updatedT;

  Offer({this.merchant, this.domain, this.title,
    this.currency, this.listPrice,
    this.price, this.shipping,
    this.condition, this.availability,
    this.link, this.updatedT});

  factory Offer.fromJson(Map<String, dynamic> json){
    num tempListPrice;
    num tempPrice;
    num tempUpdatedT;

  if (json ['list_price'] is num) {
    tempListPrice = json ['list_price'];
  }
  if (json ['price'] is num) {
    tempPrice = json ['price'];
  }
  if (json ['updated_t'] is num) {
    tempUpdatedT = json ['updated_t'];
  }
    return Offer(
        merchant: json ['merchant'] == null ? '' : json ['merchant'],
        domain: json ['domain'] == null ? '' : json ['domain'],
        title: json ['title'] == null ? '' : json ['title'],
        currency: json ['currency'] == null ? '' : json ['currency'],
        listPrice: tempListPrice == null ? 0.0 : tempListPrice,
        price: tempPrice == null ? 0.0 : tempPrice,
        shipping: json ['shipping'] == null ? '' : json ['shipping'],
        condition: json ['condition'] == null ? '' : json ['condition'],
        availability: json ['availability'] == null ? '' : json ['availability'],
        link: json ['link'] == null ? '' : json ['link'],
        updatedT: tempUpdatedT == null ? 0 : tempUpdatedT
    );
  }
}
