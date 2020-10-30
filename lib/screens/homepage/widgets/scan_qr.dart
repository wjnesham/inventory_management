import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/bloc/upc_event_state_bloc.dart';
import 'package:pantryfox/controller/upc_http_controller.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/upcUtils.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcJson.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';

import '../../../singleton.dart';

/// QR Scanner function //////////////////////////////////////////////////////

Future<void> scanQR(
    BuildContext context, UpcEventStateBloc upcBloc, GlobalKey<ScaffoldState> _scaffoldKey) async {
  bool hideDialog = true;
  try {
    ScanResult qrResult = await BarcodeScanner.scan();
    if (qrResult == null) {
      showToast(_scaffoldKey, 'Item scan unsuccessful');
      return;
    }
    if (qrResult.type == ResultType.Cancelled) {
      // Canceled scan
      return;
    }

    // >= 12
    debugPrint("_scanQR start. Length = " + qrResult.rawContent.length.toString());
    if (BarcodeFormat.ean13 == qrResult.format || qrResult.formatNote.toLowerCase() == "upc_a") {
      debugPrint("_scanQR showDialog");
      showDialog(
        context: context,
        builder: (BuildContext context) => loadingWheel(context),
      ).then((value) {
        hideDialog = false;
      });
    } else {
      // Un-handled format
      showToast(_scaffoldKey, 'Unrecognized barcode');
      return;
    }
    UpcDb upcDbResult = await upcBloc.findUpcDbInDatabase(qrResult.rawContent);
    if (upcDbResult != null && upcDbResult.code != nullString) {
      upcBloc.add(IncrementItemEvent(upcDto: upcDbResult));

      hideDialog = hideLoadingWheel(context, hideDialog);

      showToast(_scaffoldKey, 'Updated item on good scan.');
    } else {
      /// first time scan
      UpcDb goodToast = await _tryScan(context, qrResult.rawContent, upcBloc);
      hideDialog = hideLoadingWheel(context, hideDialog);
      if (goodToast != null) {
        upcBloc.add(PageJumpEvent(0, int.parse(Singleton.instance?.prefs?.getString(SettingsFormBloc.pageSize) ??
            SettingsFormBloc.defaultPageSize),goodToast.code));
        showToast(_scaffoldKey, 'Item scan successful.');
      } else {
        debugPrint("Item scan unsuccessful.");
        showToast(_scaffoldKey, 'Item scan unsuccessful.');
        return;
      }
    }
    // TODO: Determine offset.
    upcBloc.add(PageJumpEvent(
        0, //offset
        int.parse(Singleton.instance?.prefs?.getString(SettingsFormBloc.pageSize) ??
            SettingsFormBloc.defaultPageSize),
        upcDbResult.code));
    return;
  } on PlatformException catch (ex) {
    debugPrint("BarcodeScanner Some platform exception: $ex");
  } on FormatException {
    debugPrint("You pressed the back button before scanning anything");
  } on TimeoutException catch (_e) {
    debugPrint('Timeout occured: ' + _e.toString());
    hideDialog = hideLoadingWheel(context, hideDialog);
    showToast(_scaffoldKey, 'Item scan unsuccessful');
  }
  debugPrint("Error exception when item was scanned");
  hideDialog = hideLoadingWheel(context, hideDialog);
  showToast(_scaffoldKey, 'ERROR');
}

/// //////////////////////////////////////////////////////////// end _scan()
///
Future<UpcDb> _tryScan(BuildContext context, String qrResult, UpcEventStateBloc upcBloc) async {
  UpcHttpController upcController = Singleton.instance.upcController;
  UpcDb upcDb;
  Upc upcResult;
  upcResult =
      await Future.value(upcController.getFutureUpcData(qrResult)).timeout(const Duration(seconds: 10));
  if (upcResult != null) {
    itemsIsEmpty(upcResult, qrResult);

//        upcController.debugDumpScan(upcResult);
    if (upcResult.items.isEmpty) {
      debugPrint('upcResult.items.isEmpty');
      return null;
    }
    if (upcResult.items[0].title == null) {
      upcResult.items[0].title = 'No Title Found';
    }
    String imageUrl = nullString;
    if (upcResult.items[0].images.isNotEmpty) {
      imageUrl = await upcController.getWorkingImageUrl(upcResult);
    } else {
      debugPrint('Check that images array is set on items.');
      upcResult.items[0].images.add(nullString);
    }

    /// add upc to device storage.
    upcDb = await addUpcToDevice(upcResult, imageUrl, upcBloc);
  } else {
    return null;
  }

  //Set the list of UpcDb items to be displayed in ListView.
  int numberOfStoredItems = await upcBloc.countItemsScanned();
  debugPrint('You have ' + numberOfStoredItems.toString() + ' scanned into storage.');
  return upcDb;
}

///
///
void itemsIsEmpty(Upc upcResult, String qrResult) {
  if (upcResult.items.isEmpty) {
    upcResult.items = new List<Item>();
    upcResult.items.add(emptyItem(qrResult));
    if (upcResult.total == null) {
      upcResult.total = 1;
    }
    if (upcResult.code == null || upcResult.code.isEmpty) {
      upcResult.code = qrResult; //Assuming a valid scan.
    }
    debugPrint('Added empty item. Check for nulls.');
  }
}

///
///
bool hideLoadingWheel(BuildContext context, bool hide) {
  // Hide loading thingy.
  if (hide) {
    Navigator.of(context, rootNavigator: hide).pop();
  }
  return false; // Is now hidden.
}

///
///
Item emptyItem(String upc) {
  String title = LocaleKeys.titleString.tr();
  String descr = LocaleKeys.description.tr();
  List<String> imageList = new List<String>();
  imageList.add(nullString);

  return new Item(
    upc: upc,
    title: title,
    description: descr,
    images: imageList,
  );
}

///
///
// Add Upc
Future<UpcDb> addUpcToDevice(Upc upc, String goodImageUrl, UpcEventStateBloc upcBloc) async {
  if (upc.items.isEmpty || upc.items == null) {
    debugPrint("addUpcToDevice - upc.items.isEmpty || upc.items == null");
    return null;
  }
  UpcDb upcDb = Singleton.instance.upcController.getUpcDb(upc);
  if (upcDb.code == null || upcDb.code.isEmpty) {
    debugPrint("Error - Invalid upc code");
    return null;
  }
  UpcDb foundUpcDb = await upcBloc.findUpcDbInDatabase(upc.code);
  if (foundUpcDb == null ||
      foundUpcDb.code.isEmpty ||
      foundUpcDb.code == null ||
      foundUpcDb.code == nullString) {
    debugPrint('Not found in database: calling addUpcToDevice.');
    await upcBloc.addUpcToDevice(upcDb, goodImageUrl);
    return upcDb;
  } else {
    await upcBloc.updateTotal(foundUpcDb, 1);
    return foundUpcDb;
  }

  debugPrint('Returning: Updating device.');
  //add upc
}
