import 'package:flutter/material.dart';

const nullString = "null";
// const noImageUrl = 'assets/images/no_image.jpg';
const noImage = 'assets/images/bag_o_stuff_icon.png';

const VALID_UPC_LENGTH = 12;

///See https://en.wikipedia.org/wiki/Universal_Product_Code
String fixUpcToValidLength(String upcCode) {
  int len = upcCode.length;
  if (len > VALID_UPC_LENGTH) {
    debugPrint("upcCode is longer than $VALID_UPC_LENGTH = $upcCode");
    debugPrint("upcCode length = $len");
    int discardX = len - VALID_UPC_LENGTH;
    debugPrint("discardX length = $discardX");
    debugPrint("result string = ${upcCode.substring(discardX)}");
    return upcCode.substring(discardX);
  }
  return upcCode;
}
