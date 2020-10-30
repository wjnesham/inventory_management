import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jaguar_orm/jaguar_orm.dart';
import 'package:pantryfox/model/upcDb.dart';

import '../singleton.dart';

class UpcDbHistory extends Equatable {
  // @PrimaryKey()
  @PrimaryKey(auto: true)
  int id;

  @Column(isNullable: false)
  String historyKey;

  @Column(isNullable: true)
  String entryId; //deviceId

  @Column(isNullable: true)
  int entryMilliseconds;

  UpcDbHistory({@required this.historyKey, @required this.entryId, @required this.entryMilliseconds});

  static const String historyIdName = "historyId";
  static const String historyKeyName = 'historyKey';
  static const String entryIdName = 'entryId';
  static const String entryDateName = 'entryDate';

  Map<String, dynamic> toJson() =>
      {historyKeyName: this.historyKey, entryIdName: this.entryId, entryDateName: this.entryMilliseconds};

  factory UpcDbHistory.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to UpcDbHistory");
    }

    if (json[0] is num) {
      //TODO: Check if ID is correct ID.
      print('Creating UpcDbHistory from database.');
    }

    // Change this if Json is changed from the expected.
    return UpcDbHistory(
        historyKey: json[historyKeyName] == null ? "" : json[historyKeyName],
        entryId: json[entryIdName] ?? "",
        entryMilliseconds: json[entryDateName] ?? "");
  } //end class

  ///When getting an object from the database using findOne() or findAll(),
  ///those methods return the objects in a Map.
  ///This method extracts the object from the Map and returns an instance of that type.
  static UpcDbHistory getUpcDbFromMap(Map upcHistoryMap) {
    if (upcHistoryMap == null) return null;

    if (upcHistoryMap[UpcDbHistory.entryDateName] is String) {
      debugPrint("upcHistoryMap[UpcDbHistory.entryDateName] = ${upcHistoryMap[UpcDbHistory.entryDateName]}");
      UpcDbHistory upcHistoryDb = UpcDbHistory(
          historyKey: upcHistoryMap[UpcDbHistory.historyKeyName],
          entryId: upcHistoryMap[UpcDbHistory.entryIdName],
          entryMilliseconds: DateTime.now().millisecondsSinceEpoch);
      return upcHistoryDb;
    }
    UpcDbHistory upcHistoryDb = UpcDbHistory(
        historyKey: upcHistoryMap[UpcDbHistory.historyKeyName],
        entryId: upcHistoryMap[UpcDbHistory.entryIdName],
        entryMilliseconds: upcHistoryMap[UpcDbHistory.entryDateName]);

    return upcHistoryDb;
  }

  //Return a DB object from a DTO object
  static UpcDbHistory getUpcDb(UpcDb upcDto, UpcDbHistory upcHistoryDto) {
    if (upcHistoryDto == null) {
      return new UpcDbHistory(
        historyKey: getHistoryKey(upcDto.code),
        entryId: "testDevice",
        entryMilliseconds: 1, // Should this be now instead of first entry?
      );
    }
    return UpcDbHistory(
      historyKey: upcHistoryDto.historyKey,
      entryId: upcHistoryDto.entryId,
      entryMilliseconds: upcHistoryDto.entryMilliseconds,
    );
  }

  //This should be the ONLY code to build the HistoryKey
  static String getHistoryKey(String upcCode, {int key = -1}) {
    // Uuid uuid;
    // if (key == -1) {
    //   print("key = $key");
    //   uuid = Uuid();
    // }

    if (upcCode == null) {
      print("ERROR getHistoryKey - 1 or more parameters are null - returning null");
      return null;
    }
    return upcCode; // + "_" + (uuid == null ? key.toString() : uuid.v1());
  }

  static UpcDbHistory getNewHistory(String upcCode) {
    String id = Singleton.instance?.deviceId ?? "?";
    int timestamp = new DateTime.now().millisecondsSinceEpoch;
    return new UpcDbHistory(
        entryId: id, entryMilliseconds: timestamp, historyKey: getHistoryKey(upcCode));
  }


  @override
  List<Object> get props => [this.historyKey, this.entryMilliseconds];
}
