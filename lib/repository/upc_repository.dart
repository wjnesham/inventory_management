import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pantryfox/controller/upc_database.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcDbHistory.dart';

import '../singleton.dart';

abstract class UpcRepositoryInterface {
  Future<List<UpcDb>> fetchPageList({int offSet, int fetchQty, int totalQty});
  //List<UpcDb> allRows();
  //UpcDb fetchUpc(String upcCode);
  Future<UpcDb> findUpcDtoInDatabase(String code);
  Future<int> count(); //count of rows in database
  Future<int> getUpcDbIndex(String code);
  Future<void> updateTotalByOne(UpcDb upcDto, int value);
  Future<void> updateUpcDto(UpcDb upcDto);
  Future<void> setTotal(UpcDb upcDto, int value);
  // Future<void> removeOne(UpcDb upcDto);
  Future<void> addUpcToDevice(UpcDb upcDto, String goodImageUrl);

  /// Returns a sorted list of histories for a given upc code.
  Future<List<UpcDbHistory>> findUpcDbHistoriesInDatabase(String code);
}

class UpcRepository implements UpcRepositoryInterface {
  UpcSqflite upcSqflite = Singleton.instance.upcSqfliteDb;

  get f => null;

//  @override
//  List<UpcDb> allRows() async {
//    List<UpcDb> records = await upcSqflite.bean.findAll();
//    print("Start allRows. #records returned = ${records.length}");
//
//    return UpcDb.getUpcDtoList(records);
//  }

  @override
  Future<List<UpcDb>> fetchPageList({int offSet, int fetchQty, int totalQty}) async {
    debugPrint("Start fetchPageList. totalQty = $totalQty offsetPos = $offSet, fetchQty = $fetchQty ");
    if (totalQty == null || totalQty == 0) {
      return Future<List<UpcDb>>.value(new List<UpcDb>());
    }
    List<UpcDb> upcDtoList = await upcSqflite.upcBean.nextPage(offset: offSet, fetchQty: fetchQty);
    debugPrint("_nextPage() outside then #records returned = ${upcDtoList == null ? 0 : upcDtoList.length}");
    return upcDtoList == null ? Future<List<UpcDb>>.value(new List<UpcDb>()) : upcDtoList;
  }

  Future<int> getUpcDbIndex(String code) async {
    List<UpcDb> upcDbList = await upcSqflite.upcBean.findAll();
    for (int i = 0; i < upcDbList.length; i++) {
      if (upcDbList[i].code == code) {
        return i;
      }
    }
    return 0;
  }

  @override
  Future<int> count() async {
    int count = await upcSqflite.upcBean.count();
    return count;
  }

  Future<UpcDb> findUpcDtoInDatabase(String code) async {
    UpcDb upcDb = await upcSqflite.upcBean.findOne(code);
    return upcDb;
  }

  /// Returns a sorted list of histories for a given upc code.
  Future<List<UpcDbHistory>> findUpcDbHistoriesInDatabase(String code) async {
    List<UpcDbHistory> histories = await upcSqflite.historyBean.findHistories(code);
    if (histories.length > 1) {
      histories.sort((a, b) => a.entryMilliseconds.compareTo(b.entryMilliseconds));
    }

    return (histories == null ? <UpcDbHistory>[] : histories);
  }

  Future<void> updateTotalByOne(UpcDb upcDto, int value) async {
    UpcDb upcDb = await upcSqflite.upcBean.findOne(upcDto.code);
    if (upcDb == null) {
      debugPrint("updateTotalByOne ERROR - cannot find upcDb in datahase!");
      return;
    }
    await upcSqflite.upcBean.updateTotal(upcDb, value);
  }

  /// Is this the same as updateTotalByOne?
  @override
  Future<void> setTotal(UpcDb upcDto, int value) async {
    UpcDb upcDb = await upcSqflite.upcBean.findOne(upcDto.code);
    if (upcDb == null) {
      debugPrint("updateTotalByOne ERROR - cannot find upcDb in datahase!");
      return;
    }
    await upcSqflite.upcBean.setTotal(upcDb, value);
  }

  // Future<void> removeOne(UpcDb upcDto) async {
  //   UpcDb upcDb = await upcSqflite.bean.findOne(upcDto.code);
  //   if (upcDb == null) {
  //     debugPrinter("removeOne ERROR - cannot find upcDb in datahase!");
  //     return;
  //   }
  //   await upcSqflite.bean.removeOne(upcDb.code);
  // }

  Future<void> addUpcToDevice(UpcDb upcDto, String goodImageUrl) async {
    debugPrint("start addUpcToDevice");
    await upcSqflite.upcBean.addUpcToDevice(upcDto, goodImageUrl);
  }

  /// upcDto is an updated UpcDb.
  @override
  Future<void> updateUpcDto(UpcDb upcDto) async {
    if (upcDto == null) {
      debugPrint("Failed to update UpcDb in repository.");
      return;
    }
    await upcSqflite.upcBean.updateUpcDbFields(upcDto, true);
  }
}
