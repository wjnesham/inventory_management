import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pantryfox/controller/upc_database.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcDbHistory.dart';
import 'package:pantryfox/singleton.dart';
import 'package:sqflite/sqlite_api.dart';

class FireStoreService {
  //uid returned from auth
  //ties uid to data
  final String uid;
  FireStoreService({@required this.uid});

  // ******** pantryProfileCollection reference *********
  final CollectionReference pantryProfileCollection = FirebaseFirestore.instance.collection('pantryProfile');

  static DocumentReference upcFire;

  Future<void> updateUserData(String name, String email, String deviceID, String itemPageSize) async {
    return await pantryProfileCollection.doc(uid).collection('user').doc(deviceID).set({
      'name': name,
      'email': email,
      'itemPageSize': itemPageSize,
    });
  }

  // get pantryProfile for this device/user
  Future<Map> getUserProfile(String deviceID) async {
    DocumentReference documentReference = pantryProfileCollection.doc(uid).collection('user').doc(deviceID);
    DocumentSnapshot userRef = await documentReference.get();
    var data = userRef.data();
    return data;
  }

// ********                         *********
// ******** upcCollection reference *********
// ********                         *********
  final CollectionReference upcCollection = FirebaseFirestore.instance.collection('upcData');

  Map historyListToMap(List historyList) {
    Map<String, String> histMap = Map();
    if (historyList == null) return histMap;

    for (UpcDbHistory history in historyList) {
      histMap.putIfAbsent(history.entryMilliseconds.toString(), () => history.entryId);
    }
    return histMap;
  }

  Future<Map> updateHistoryData(UpcDb upcDb, Map upcDocMap) async {
    // contains all histories
    List histories = await Singleton.instance.upcSqfliteDb.historyBean.findHistories(upcDb.code);

    Map historyMap = historyListToMap(histories);
    Map currentUpcHistoryMap;
    if (upcDocMap != null) {
      if (upcDocMap.containsKey(UpcDb.historiesName)) {
        currentUpcHistoryMap = upcDocMap[UpcDb.historiesName];
      }
    }

    if (currentUpcHistoryMap != null) {
      if (currentUpcHistoryMap.length == histories.length) {
        return currentUpcHistoryMap ?? Map();
      }
    }

    return historyMap ?? Map();
  }

  /// Only call this if the user has data
  Future<Map> setUpcDocRef(String code) async {
    // Get upc document reference
    upcFire = upcCollection.doc(uid).collection('upc').doc(code);

    // get doc snapshot for upc from firebase
    DocumentSnapshot upcDoc = await upcFire.get();
    Map upcDocMap = upcDoc.data();
    if (upcDocMap == null || upcDocMap.isEmpty) {
      debugPrint("No data for UPC code in firestore.dart when doing setUpcDocRef!");
      return null;
    }
    return upcDocMap;
  }

  bool checkIfFirestoreHasChanges(UpcDb upcDb, Map upcDocMap) {
    try {
      bool hasChanges = (upcDocMap[UpcDb.totalName] != upcDb.total ||
          upcDocMap[UpcDb.titleName] != upcDb.title ||
          upcDocMap[UpcDb.descriptionName] != upcDb.description ||
          upcDocMap[UpcDb.imageLinkName] != upcDb.imageLink ||
          upcDocMap[UpcDb.cupboardName] != upcDb.cupboard ||
          upcDocMap[UpcDb.brandName] != upcDb.brand ||
          upcDocMap[UpcDb.modelName] != upcDb.model ||
          upcDocMap[UpcDb.priceName] != upcDb.price ||
          upcDocMap[UpcDb.weightName] != upcDb.weight ||
          upcDocMap[UpcDb.selectedName] != upcDb.selected);

      return hasChanges;
    } on Exception {
      return true;
    }
  }

  /// Check this before calling updateUpcData.
  Future<bool> upcCollectionHasData() async {
    var upcData = await upcCollection.doc(uid).collection('upc').get();
    if (upcData == null) {
      debugPrint("Create upc collection before updating it!");
      return false;
    }
    if (upcData.size > 0) return true;
    //else
    return false;
  }

  Future<void> updateUpcData(UpcDb upcDb) async {
    if (upcDb == null) return;
    bool needsData = false;

    Map upcDocMap = await setUpcDocRef(upcDb.code);
    if (upcDocMap == null) {
      debugPrint("User has no data in firestore for upc ${upcDb.code}");
      needsData = true;
    } else {
      needsData = checkIfFirestoreHasChanges(upcDb, upcDocMap);
    }

    Map historyMap = await updateHistoryData(upcDb, upcDocMap);
    Map currentHistories;

    if (upcDocMap != null) {
      currentHistories = upcDocMap.containsKey(UpcDb.historiesName) ? upcDocMap[UpcDb.historiesName] : Map();
    }
    if (historyMap?.length != currentHistories?.length) {
      needsData = true;
    }

    if (needsData) {
      debugPrint("Data was changed - calling set. upcDb.total =  ${upcDb.total}");
      await upcFire.set({
        UpcDb.historiesName: historyMap,
        UpcDb.totalName: upcDb.total,
        UpcDb.titleName: upcDb.title,
        UpcDb.descriptionName: upcDb.description,
        UpcDb.imageLinkName: upcDb.imageLink,
        UpcDb.cupboardName: upcDb.cupboard,
        UpcDb.brandName: upcDb.brand,
        UpcDb.modelName: upcDb.model,
        UpcDb.priceName: upcDb.price,
        UpcDb.weightName: upcDb.weight,
        UpcDb.selectedName: upcDb.selected,
      });
    } else {
      // Nothing to set
      debugPrint("Nothing was changed");
    }
  }

  ///Take all local data and insert to firebase
  Future<void> backupUpcDataToFirebase() async {
    List<UpcDb> recordList = await Singleton.instance.upcSqfliteDb.upcBean.findAll();
    for (UpcDb upcDb in recordList) {
      await updateUpcData(upcDb);
    }
  }

  Future<UpcDb> retrieveUpcDbFromFirestore(String upcCode) async {
    DocumentSnapshot snapshot = await upcCollection.doc(uid).collection('upc').doc(upcCode).get();
    if (snapshot == null) {
      print("retrieveUpcDbFromFirestore returned null");
      return null;
    }
    return upcFromDocumentSnapshot(snapshot);
  }

  /// Retrieve ALL firebase upc data
  /// Do not call this except when restoring the SQLite database or for testing
  Future<List<DocumentSnapshot>> retrieveAllUpcDataFromFirestore() async {
    QuerySnapshot querySnapshot = await upcCollection.doc(uid).collection('upc').get();
    List<DocumentSnapshot> snapshotList = querySnapshot.docs;
    if (snapshotList == null || snapshotList.isEmpty) {
      return null;
    }
    return snapshotList;
  }

  /// This method deletes all from sqlLite and inserts to sqlLite records from firebase
  Future<void> restoreUpcDataFromFirestore() async {
    List<DocumentSnapshot> snapshotList = await retrieveAllUpcDataFromFirestore();
    if (snapshotList == null || snapshotList.isEmpty) {
      return;
    }
    await Singleton.instance.upcSqfliteDb.upcBean.removeAll();
    await Singleton.instance.upcSqfliteDb.historyBean.removeAll();

    snapshotList.forEach((productDoc) async => await _loadUpc(productDoc));

    await Singleton.instance.upcSqfliteDb.upcBean.count().then((val) {
      print("Number of records after load from firebase is ${val.toString()}");
    });
  }

  Future<void> _loadUpc(DocumentSnapshot upcDoc) async {
    UpcDb upcDb;
    try {
      upcDb = upcFromDocumentSnapshot(upcDoc);

      await Singleton.instance.upcSqfliteDb.upcBean.addUpcToDevice(upcDb, upcDb.imageLink);

      bool didFetchHistories = await fetchHistories(upcDoc, upcDb.code);
      if (didFetchHistories) {
        debugPrint("Fetched Histories for ${upcDb.code}!");
      } else {
        debugPrint("Failed to fetch Histories for ${upcDb.code}!");
      }

      // await Singleton.instance.upcSqfliteDb.bean.insert(upcDb);
      debugPrint("Firestore.dart inserted upc from doc into sqflite.");
    } on DatabaseException catch (ex) {
      printWarning(ex.toString());
    }
  }

  /// Inserts all histories for upc from Firebase.
  Future<bool> fetchHistories(DocumentSnapshot upcDoc, String upcCode) async {
    //Histories
    Map histMap = upcDoc.data()[UpcDb.historiesName] ?? Map();
    if (histMap == null || histMap.isEmpty) {
      return false;
    }

    histMap.forEach((key, value) async {
      UpcDbHistory dhHist = _upcDbHistoryFromKeyValue(key, value, upcCode);
      await Singleton.instance.upcSqfliteDb.historyBean.insert(dhHist);
    });
    return true;
  }

  UpcDbHistory _upcDbHistoryFromKeyValue(String entryTime, String deviceId, String upcCode) {
    if (entryTime == null || entryTime.isEmpty || deviceId == null) {
      return null;
    }
    int time = int.parse(entryTime);
    return UpcDbHistory(historyKey: upcCode, entryId: deviceId, entryMilliseconds: time);
  }

  UpcDb upcFromDocumentSnapshot(DocumentSnapshot snapshot) {
    final doc = snapshot.data();

    UpcDb upcDb = new UpcDb(
      brand: doc[UpcDb.brandName],
      code: snapshot.id,
      total: doc[UpcDb.totalName],
      title: doc[UpcDb.titleName],
      description: doc[UpcDb.descriptionName],
      imageLink: doc[UpcDb.imageLinkName],
      cupboard: doc[UpcDb.cupboardName],
      model: doc[UpcDb.modelName],
      price: doc[UpcDb.priceName],
      weight: doc[UpcDb.weightName],
      selected: doc[UpcDb.selectedName],
    );
    upcDb.histories = doc[UpcDb.historiesName];
    return upcDb;
  }

  Future<void> createTestUpcDbItem() async {
    UpcDb upcDb = new UpcDb();

    upcDb.total = 99;
    upcDb.title = UpcDb.titleName;
    upcDb.description = UpcDb.descriptionName;
    upcDb.imageLink = UpcDb.imageLinkName;
    upcDb.cupboard = UpcDb.cupboardName;
    upcDb.brand = UpcDb.brandName;
    upcDb.model = UpcDb.modelName;
    upcDb.price = UpcDb.priceName;
    upcDb.weight = UpcDb.weightName;
    upcDb.selected = false;

    await updateUpcData(upcDb);
  }


  Future<bool> syncData() async {
    bool syncSuccess = await syncAllData();
    return syncSuccess;
  }

  ///Retrieves all data used for syncDataBetweenFirebaseAndSqlFlite
  ///We should avoid and only get what has changed.
  Future<bool> syncAllData() async {
    bool syncSuccess = false;
    bool sqlFliteHasData = false;
    bool fireStoreHasData = false;

    List<UpcDb> firestoreUpcList = List<UpcDb>();

    // Check Sqflite
    List<UpcDb> sqlFliteRecordList = await Singleton.instance.upcSqfliteDb.upcBean.findAll();
    if (sqlFliteRecordList != null && sqlFliteRecordList.isNotEmpty) {
      sqlFliteHasData = true;
      debugPrint("sqlFliteHasData = true");
    } else {
      debugPrint("sqlFliteHasData = false");
    }

    // TODO: Only get ones that aren't already synced on device.
    // TODO: Create Firebase Function to get all that aren't marked for delete, aren't on device, and
    // have changes
    List<DocumentSnapshot> snapshotList = await retrieveAllUpcDataFromFirestore();
    if (snapshotList != null && snapshotList.isNotEmpty) {
      fireStoreHasData = true;
    }

    if (!sqlFliteHasData && !fireStoreHasData) {
      debugPrint("No data found - try scanning something.");
      syncSuccess = true; //they are in sync - both have no data!
      return syncSuccess;
    }

    if(snapshotList != null) {
      //Method for unit test
      UpcDb upcDb;
      snapshotList.forEach((upcDoc) {
        upcDb = upcFromDocumentSnapshot(upcDoc);
        if (upcDb != null) {
          firestoreUpcList.add(upcDb);
        }
      });
    } else {
      firestoreUpcList = List<UpcDb>();
    }

    syncSuccess = await syncDataBetweenFirebaseAndSqlFlite(firestoreUpcList, sqlFliteRecordList);

    return syncSuccess;
  }

  /// Make data between SqlFlite and Firestore the same
  /// The concerns are:
  /// 1. No SqlFlite UpcDb record exists, but there is a Firestore UpcDb
  /// 2. No Firestore UpcDb record exists, but there is a SqlFlite UpcDb
  /// 3. The UpcDb exists in both, but their histories are different
  ///   3a. More SqlFlite histories than Firestore histories
  ///   3b. More Firestore histories than SqlFlite histories
  ///   3c. History count is equal, but timestamps differ - needs to be cleaned
  ///
  /// 4. make sure total on main record matches number of histories
  ///
  /// This is expensive, so may want to allow x times per month this is called.
  /// If the user wants more, he can pay for it!
  Future<bool> syncDataBetweenFirebaseAndSqlFlite(List<UpcDb> firestoreUpcList, List<UpcDb> sqlFliteUpcList) async {
    bool syncSuccess = false;
    bool sqlFliteHasData = sqlFliteUpcList.isNotEmpty;
    bool fireStoreHasData = firestoreUpcList?.isNotEmpty;

    //At this point there are 2 lists, 1 for SQLFlite and 1 for Firestore.
    //One of them MAY be empty, but that's ok

    UpcDb firestoreUpcDb;
    if (sqlFliteHasData) {
      //Method for unit test
      sqlFliteUpcList.forEach((sqlRecord) async {
        // Set FireStore document reference
        upcFire = upcCollection.doc(uid).collection('upc').doc(sqlRecord.code);
        // Check if upc code is in FireStore
        firestoreUpcDb =
            firestoreUpcList.firstWhere((fireStoreUpc) => fireStoreUpc == sqlRecord, orElse: () => null);
        if (firestoreUpcDb == null) {
          ///exists in SQLFlite but not Firestore - update fireStore
          // Get histories from device
          List histories = await Singleton.instance.upcSqfliteDb.historyBean.findHistories(sqlRecord.code);
          Map historyMap = historyListToMap(histories);
          // Add to FireStore
          await addUpcAndHistoryToFirestore(historyMap, sqlRecord);
        } else {
          ///exists in both, make histories match (use a new method to avoid lots of code here)
          await getSyncedHistoryMap(firestoreUpcDb);

          // Add upc and histories to Firestore
          //await addUpcAndHistoryToFirestore(sqfliteHistoryMap, sqlRecord);

          ///remove from firestoreList and historyMap since already synced, and
          ///won't need to sync later in this method
          firestoreUpcList.remove(firestoreUpcDb);

        }
      });
    }

    syncSuccess = true;
    //The firestoreUpcList may have been emptied so we are done
    if (firestoreUpcList.isEmpty) {
      return syncSuccess;
    }

    //Method for unit test
    /// Go through remaining Firestore records. These should only be in FireStore.
    firestoreUpcList.forEach((keyUpc) {
      // Add histories
      //fetchHistories(snapValue, keyUpc.code);
      // Add Upc data
      //Singleton.instance.upcSqfliteDb.upcBean.insert(keyUpc);
    });

    return syncSuccess;
  }

  /// Returns a map of synced histories.
  /// Should be called when upc is in both Firestore and SqFlite.
  Future<void> getSyncedHistoryMap(UpcDb firestoreUpcDb) async {
    UpcDbHistory upcHistoryTemp;
    // Get history maps for both and delete where DELETEDs
    List<UpcDbHistory> sqlLiteHistories =
        await Singleton.instance.upcSqfliteDb.historyBean.findHistories(firestoreUpcDb.code);

    //= historyListToMap(sqlLiteHistories);

    /// 1. Find new ones from FS not in SQL, add FS to sqfliteHistoryMap
    Map sqfliteHistorySyncMap = Map();
    if(firestoreUpcDb?.histories?.isNotEmpty == true) {
      firestoreUpcDb.histories.forEach((key, value) {
        upcHistoryTemp = sqlLiteHistories.firstWhere((element) => key == element.entryMilliseconds, orElse: () => null);
        if(upcHistoryTemp == null) {
          sqfliteHistorySyncMap.putIfAbsent (upcHistoryTemp.entryMilliseconds, () => upcHistoryTemp.entryId);
        }
      });
    }


    /// 2. Find new ones from SQL not in FS, add SQL to sqfliteHistoryMap
    /// removed DELETED from FS
    sqlLiteHistories.forEach((upcDbHistory) {
      if(firestoreUpcDb.histories.containsKey(upcDbHistory.entryMilliseconds)) {
        if(upcDbHistory.entryId.contains(UpcSqflite.DELETED)) {
          firestoreUpcDb.histories.remove(upcDbHistory.entryMilliseconds);
        }
      } else {
        //not in FS, but is in SQLlite
        firestoreUpcDb.histories.putIfAbsent(upcDbHistory.entryMilliseconds, () => upcDbHistory.entryId);
      }
    });

    int totalAmt = sqfliteHistorySyncMap?.length ?? 0;
    await Singleton.instance.upcSqfliteDb.upcBean.setTotal(firestoreUpcDb, totalAmt);

    // delete histories marked d=for deletion
    await Singleton.instance.upcSqfliteDb.historyBean.removeMarkedHistoriesAfterSync(sqlLiteHistories);

    return;
  }

  /// Must set upcFire document reference before calling
  Future<void> addUpcAndHistoryToFirestore(Map historyMap, UpcDb upcDb) async {
    if (upcFire == null) {
      debugPrint("Forgot to set upcFire document reference before addUpcAndHistoryToFirestore!!");
      return;
    }
    await upcFire.set({
      UpcDb.historiesName: historyMap,
      UpcDb.totalName: upcDb.total,
      UpcDb.titleName: upcDb.title,
      UpcDb.descriptionName: upcDb.description,
      UpcDb.imageLinkName: upcDb.imageLink,
      UpcDb.cupboardName: upcDb.cupboard,
      UpcDb.brandName: upcDb.brand,
      UpcDb.modelName: upcDb.model,
      UpcDb.priceName: upcDb.price,
      UpcDb.weightName: upcDb.weight,
      UpcDb.selectedName: upcDb.selected,
    });
  }
}
