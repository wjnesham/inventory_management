import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantryfox/model/upcDbHistory.dart';
import 'package:pantryfox/repository/upc_repository.dart';
import 'package:pantryfox/screens/settings/widgets/settings_bloc.dart';
import 'package:pantryfox/helper/upcUtils.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:jaguar_orm/jaguar_orm.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../singleton.dart';

//examples: https://github.com/jaguar-orm/sqflite

/// The adapter
SqfliteAdapter _upcAdapter;

///Name of the file/database holding scanned data - unit tests can change it as needed
///when adding or removing columns from the schema, need to increment filename by 1
String upcFileName = "/upcFile8.json";

class UpcSqflite {

  UpcBean upcBean;
  HistoryBean historyBean;

  static const DELETED = "DELETED";

  init(String databaseFileName) async {
    if (_upcAdapter == null) {
      if (databaseFileName != null) {
        upcFileName = databaseFileName;
      }
      _upcAdapter = new SqfliteAdapter(await getDatabasesPath() + upcFileName, version: 1);
    }
    if (upcBean == null) {
      try {
        await _upcAdapter.connect();
      } catch (e) {
        debugPrint("Cannot connect to database");
        debugPrint(e.toString());
      }
      upcBean = new UpcBean();
    } else {
      debugPrint("Calling init and upcBean is not null. Calling init multiple times is bad.");
    }

    await upcBean.createTable();

    // History bean
    if (historyBean == null) {
      historyBean = new HistoryBean();
      await historyBean.createTable();
    } else {
      debugPrint("**Warning: Calling init and historyBean is not null!**");
    }
  }

  close() async {
    await _upcAdapter.close();
  }
}

class HistoryBean {
  // Primary key
  // final IntField id = IntField(UpcDbHistory.historyIdName);
  final StrField code = new StrField(UpcDbHistory.historyKeyName);
  final StrField entryId = new StrField(UpcDbHistory.entryIdName);
  final IntField entryDate = new IntField(UpcDbHistory.entryDateName);

  static const String historyTableName = 'history_table';

  /// Inserts a new record into table
  Future insert(UpcDbHistory history) async {
    try {
      final insert = Insert(historyTableName).setValues({
        UpcDbHistory.historyKeyName: history.historyKey,
        UpcDbHistory.entryIdName: history.entryId,
        UpcDbHistory.entryDateName: history.entryMilliseconds,
      });

      return await insert.exec(_upcAdapter);
    } on DatabaseException {
      printInfo("**Warning: Table created incorrectly.**");
    }
  }

  Future<int> removeAll() async {
    Remove deleter = new Remove(historyTableName);
    return await _upcAdapter.remove(deleter);
  }

  /// Remove marked histories after syncing to FireStore
  Future<void> removeMarkedHistoriesAfterSync(List<UpcDbHistory> deletedHistories) async {
    if (deletedHistories == null) {
      debugPrint("NULL list of histories was detected when removeMarkedHistoriesAfterSync was called");
      return;
    }
    for (UpcDbHistory history in deletedHistories) {
      if (history.entryId.trim().contains(UpcSqflite.DELETED)) {
        Remove deleter = new Remove(historyTableName).where(this.entryId.eq(history.entryId));
        await _upcAdapter.remove(deleter);
      }
    }
  }

  /// Mark all for DELETion
  Future<int> markAllHistoriesFromUpcAsDeleted(String upcCode) async {
    var histories = await Singleton.instance.upcSqfliteDb.historyBean.findHistories(upcCode);
    if (histories == null) {
      debugPrint("No histories to delete for $upcCode");
      return 0;
    }

    int numOfChanges = 0;
    try {
      histories.forEach((hist) async {
        if (!hist.entryId.contains(UpcSqflite.DELETED)) {
          await _markHistoryAsDELETED(hist);
          numOfChanges++;
        }
      });
      if (numOfChanges == 0)
        debugPrint("All histories for upc given were already marked.");
      else
        debugPrint("Removed all histories for upc given.");
    } on Exception catch (e) {
      debugPrint("upcDB ERROR: ${e.toString()} couldn't be marked!");
      numOfChanges = -1;
    }
    // Return number of histories that were marked.
    return numOfChanges;
  }

  /// Mark for DELETion
  Future<void> _markHistoryAsDELETED(UpcDbHistory history) async {
    Update update = new Update(historyTableName)
        .where(this.entryDate.eq(history.entryMilliseconds))
        .setValue(UpcDbHistory.entryIdName, (history?.entryId ?? "Error") + UpcSqflite.DELETED);

    await _upcAdapter.update(update);
  }

  // TODO
  /// Mark first history for given upc code for DELETion
  Future<UpcDbHistory> markFirstHistoryForUpcAsDeleted(String upcCode) async {
    UpcRepositoryInterface upcRepository = UpcRepository();
    List<UpcDbHistory> histories = await upcRepository.findUpcDbHistoriesInDatabase(upcCode);
    if (histories == null || histories.isEmpty) {
      debugPrint("Unable to findhistories for $upcCode");
      return null;
    }

    // Remove remover = new Remove(historyTableName);
    UpcDbHistory histDelete;
    for (UpcDbHistory hist in histories) {
      // check if null
      if (hist.entryId == null) {
        debugPrint("Marking an invalid history for DELETion.");
        hist.entryId = "Error";
      }
      if (!hist.entryId.contains(UpcSqflite.DELETED)) {
        histDelete = hist;
        break;
      }
    }
    if (histDelete == null) {
      debugPrint("All histories were already marked for DELETED");
      return null;
    }

    await _markHistoryAsDELETED(histDelete);
    histDelete.entryId += UpcSqflite.DELETED;
    debugPrint("millisec = " + histDelete.entryMilliseconds.toString() + " was marked for deletion...");

    return histDelete;
  }

  Future<void> createTable() async {
    final historyTableEntry = new Create(historyTableName, ifNotExists: true);
    historyTableEntry
        .addAutoPrimaryInt(UpcDbHistory.historyIdName)
        .addStr(UpcDbHistory.entryIdName, isNullable: true)
        .addInt(UpcDbHistory.entryDateName, isNullable: false)

        // primary key
        .addStr(UpcDbHistory.historyKeyName);

    await _upcAdapter.createTable(historyTableEntry);
  }

  /// Finds List of Histories by [code]
  /// Returns null if map is empty.
  Future<List<UpcDbHistory>> findHistories(String code) async {
    List<UpcDbHistory> histories = <UpcDbHistory>[];
    Find finder = new Find(historyTableName);
    finder.where(this.code.eq(code));
    List<Map> upcHistMap = await _upcAdapter.find(finder);
    if (upcHistMap == null) {
      debugPrint("upcHistMap not found for '$code' in DB.");
      return null;
    }

    for (Map map in upcHistMap) {
      histories.add(UpcDbHistory.getUpcDbFromMap(map));
    }

    return histories;
  }
} //HistoryBean

class UpcBean {
  /// DSL Fields
  final StrField code = new StrField(UpcDb.codeName);
  final IntField total = new IntField(UpcDb.totalName);
  final StrField title = new StrField(UpcDb.titleName);
  final StrField description = new StrField(UpcDb.descriptionName);
  final StrField imageLink = new StrField(UpcDb.imageLinkName);
  //new
  final StrField cupboard = new StrField(UpcDb.cupboardName);
  final StrField brand = new StrField(UpcDb.brandName);
  final StrField model = new StrField(UpcDb.modelName);
  final StrField price = new StrField(UpcDb.priceName);
  final StrField weight = new StrField(UpcDb.weightName);
  final BoolField selected = new BoolField(UpcDb.selectedName);

  setTimeToIntField(int millisecondsSinceEpoch) {}

  /// Table name for the model this bean manages
  String get upcTableName => 'upc_table';

  /// Inserts a new record into table
  Future insert(UpcDb item) async {
    final insert = Insert(upcTableName).setValues({
      UpcDb.codeName: item.code,
      UpcDb.totalName: item.total,
      UpcDb.titleName: item.title,
      UpcDb.descriptionName: item.description,
      UpcDb.imageLinkName: item.imageLink,
      UpcDb.cupboardName: item.cupboard,
      UpcDb.brandName: item.brand,
      UpcDb.modelName: item.model,
      UpcDb.priceName: item.price,
      UpcDb.weightName: item.weight,
      UpcDb.selectedName: item.selected,
    });

    return await insert.exec(_upcAdapter); //_adapter.insert(inserter);
  }

  Future<Null> createTable() async {
    final upcTableEntry = new Create(upcTableName, ifNotExists: true);
    upcTableEntry
        .addStr(UpcDb.titleName, isNullable: true)
        .addStr(UpcDb.totalName, isNullable: true)
        .addStr(UpcDb.descriptionName, isNullable: true)
        .addStr(UpcDb.imageLinkName, isNullable: true)
        .addStr(UpcDb.cupboardName, isNullable: true)
        .addStr(UpcDb.brandName, isNullable: true)
        .addStr(UpcDb.modelName, isNullable: true)
        .addStr(UpcDb.priceName, isNullable: true)
        .addStr(UpcDb.weightName, isNullable: true)
        .addBool(UpcDb.selectedName, isNullable: true)
        // primary key
        .addPrimaryStr(UpcDb.codeName);

    await _upcAdapter.createTable(upcTableEntry);
  }

  /// Finds one post by [code]
  Future<UpcDb> findOne(String code) async {
    //print("findOne code = $code");
    Find updater = new Find(upcTableName);
    updater.where(this.code.eq(code));
    Map upcMap = await _upcAdapter.findOne(updater);
    if (upcMap == null || upcMap.isEmpty) return null;
    //print("findOne calling getUpcDbFromMap");
    UpcDb upc = UpcDb.getUpcDbFromMap(upcMap);
    return upc;
  }

  /// Group of rows determined by offset
  Future<List<UpcDb>> nextPage({int offset, int fetchQty}) async {
    //https://github.com/Jaguar-dart/jaguar_orm/wiki/Find-statement
    String orderPref = Singleton.instance.prefs?.getString(SettingsFormBloc.orderBy.toLowerCase()) ?? "title";
    Find finder = new Find(upcTableName).orderBy(orderPref).offset(offset).limit(fetchQty);

    List<Map> maps = (await _upcAdapter.find(finder)).toList();
    List<UpcDb> upcDbsList = new List<UpcDb>();
    UpcDb upcDb;
    for (Map map in maps) {
      upcDb = UpcDb.getUpcDbFromMap(map);
      if (upcDb == null) continue;
      upcDbsList.add(UpcDb.getUpcDbFromMap(map));
    }
    return upcDbsList;
  }

  Future<List<UpcDb>> findAll() async {
    Find finder = new Find(upcTableName);

    List<Map> maps = (await _upcAdapter.find(finder)).toList();
    List<UpcDb> upcDbsList = <UpcDb>[];
    UpcDb upcDb;
    for (Map map in maps) {
      upcDb = UpcDb.getUpcDbFromMap(map);
      if (upcDb == null) continue;
      upcDbsList.add(upcDb);
    }

    return upcDbsList;
  }

  Future<int> count() async {
    Find finder = new Find(upcTableName).count(UpcDb.codeName);
    int value = 0;
    try {
      Map map = (await _upcAdapter.find(finder)).first;
      value = map['COUNT(code)'];
    } catch (e) {
      debugPrint(e);
    }

    return value == null ? 0 : value;
  }

  Future<void> setTotal(UpcDb upcDb, int totalAmt) async {
    UpcDb foundInList = await findOne(upcDb.code);
    if (foundInList != null) {
      foundInList.total = totalAmt;

      /// Set selected index
      foundInList.selected = true;

      Update updater = new Update(upcTableName);
      try {
        updater.where(this.code.eq(foundInList.code));

        // await Singleton.instance.upcSqfliteDb.historyBean.insert();
        // TODO: update histories

        updater.set(this.total, foundInList.total);
        updater.set(this.selected, foundInList.selected);
        await _upcAdapter.update(updater);
      } on PlatformException catch (e) {
        print("(upc_database) WARNING: $e");
      }

      upcDb.total = foundInList.total;
      return foundInList.total;
    } else {
      debugPrint("setTotal: Did not find upcDb in list");
    }
  }

  /// Update histories in DB based on count update.
  Future updateHistories(int count, UpcDb upcDb) async {
    UpcRepositoryInterface upcRepository = UpcRepository();
    List<UpcDbHistory> histories = await upcRepository.findUpcDbHistoriesInDatabase(upcDb.code);

    if (count > 0) {
      int milliTime = DateTime.now().millisecondsSinceEpoch;
      String deviceId = Singleton.instance.deviceId;
      UpcDbHistory history =
          UpcDbHistory(entryId: deviceId, entryMilliseconds: milliTime, historyKey: upcDb.code);
      // insert
      await Singleton.instance.upcSqfliteDb.historyBean.insert(history);
    } else if (count == -1 && histories.isNotEmpty && upcDb.total >= count) {
      UpcDbHistory removedHistory =
          await Singleton.instance.upcSqfliteDb.historyBean.markFirstHistoryForUpcAsDeleted(upcDb.code);
      debugPrint("History at " + removedHistory.entryMilliseconds.toString() + "ms was removed from db");
      // remove earliest entry for given list of histories.
    } else if (count < -1 && histories.isNotEmpty && upcDb.total >= count) {
      await Singleton.instance.upcSqfliteDb.historyBean.markAllHistoriesFromUpcAsDeleted(upcDb.code);
    }
  }

  /// Only updates the total...
  /// totalAmt = -1 if deleting one
  Future<int> updateTotal(UpcDb upcDb, int totalAmt) async {
    UpcDb foundInList = await findOne(upcDb.code);
    if (foundInList != null) {
      foundInList.total += totalAmt;
      //Singleton.instance.upcUniqueQty += totalAmt;
      debugPrint("after updateTotal, upcQty = ${foundInList.total}.");

      /// Set selected index
      foundInList.selected = true;

      Update updater = new Update(upcTableName);
      try {
        updater.where(this.code.eq(foundInList.code));

        await updateHistories(totalAmt, foundInList);

        updater.set(this.total, foundInList.total);
        updater.set(this.selected, foundInList.selected);

        await _upcAdapter.update(updater);
      } on DatabaseException catch (e) {
        print("(upc_database) WARNING: $e");
      }

      upcDb.total = foundInList.total;
      return foundInList.total;
    } else {
      debugPrint("updateTotal: Did not find upcDb in list");
    }
    return 0;
  }

  Future<void> updateUpcDbFields(UpcDb upcDb, bool foundInList) async {
    if (upcDb == null) {
      debugPrint('Null upcDb passed in. UpcDb was not updated.');
      return;
    }
    if (!foundInList) {
      debugPrint('Upc not found: UpcDb was not updated.');
      return;
    }

    Update updater = new Update(upcTableName);
    if (updater.where(this.code.eq(upcDb.code)) != null) {
      updater.where(this.code.eq(upcDb.code));

      updater.set(this.total, upcDb.total);
      updater.set(this.code, upcDb.code);
      updater.set(this.title, upcDb.title);
      updater.set(this.description, upcDb.description);
      updater.set(this.imageLink, upcDb.imageLink);
      updater.set(this.brand, upcDb.brand);
      updater.set(this.model, upcDb.model);
      updater.set(this.weight, upcDb.weight);
      updater.set(this.selected, upcDb.selected);

      // TODO: update histories
      // await Singleton.instance.upcSqfliteDb.historyBean.insert(upcDb.historyKey);
      // update histories

      await _upcAdapter.update(updater);
    } else {
      debugPrint('Upc matched null: UpcDb was not updated.');
    }
  }

  // Removes one by upc code.
  Future<void> removeOne(String barCode) async {
    Remove deleter = new Remove(upcTableName);
    deleter.where(this.code.eq(barCode));
    return await _upcAdapter.remove(deleter);
  }

  Future<int> removeAll() async {
    Remove deleter = new Remove(upcTableName);
    return await _upcAdapter.remove(deleter);
  }

  ///return false if found in database - that is, not added to database because found
  ///may want to add exception handler if db fails
  Future<UpcDb> addUpcToDevice(UpcDb upcDb, String goodImageUrl) async {
    if (upcDb.code == null || upcDb.code.isEmpty || upcDb.code == nullString) {
      debugPrint('Failed to add upcDb to device.');
      return upcDb;
    }

    UpcDb foundUpc = await findOne(upcDb.code);
    if (foundUpc != null && foundUpc.code == upcDb.code) {
      int total = foundUpc.total;
      debugPrint("found ${foundUpc.code} in database! count = $total");

      await updateTotal(foundUpc, 1);
      if (foundUpc.total == total) {
        debugPrint('After update, the value of total was still the same.');
      }

      // TODO: Set histories
      // foundUpc.historyKey = upcDb.historyKey;
      // await Singleton.instance.upcSqfliteDb.historyBean.insert(foundUpc.historyKey);
      return foundUpc;
    }

    upcDb.imageLink = goodImageUrl ?? "";
    var upcDbHistoryKey = UpcDbHistory.getHistoryKey(upcDb.code);
    UpcDbHistory dbHistory = UpcDbHistory(
        historyKey: upcDbHistoryKey,
        entryId: Singleton.instance.deviceId,
        entryMilliseconds: DateTime.now().millisecondsSinceEpoch);
    await Singleton.instance.upcSqfliteDb.historyBean.insert(dbHistory);

    await insert(upcDb);

    debugPrint('Added upcDb to device.');
    //added upc
    return upcDb;
  }
}
