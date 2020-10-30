import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:pantryfox/bloc/upc_event.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/repository/upc_repository.dart';
import 'package:pantryfox/singleton.dart';

import '../screens/settings/widgets/settings_bloc.dart';

///https://stackoverflow.com/questions/55776041/what-does-yield-keyword-do-in-flutter
///https://stackoverflow.com/questions/58138791/what-does-the-child-class-of-equatable-pass-to-the-superequatable-class

abstract class UpcState extends Equatable {
  const UpcState();
}

class UpcInitialDtoState extends UpcState {
  const UpcInitialDtoState();
  @override
  List<UpcDb> get props => [];
}

class UpcLoadedDtoState extends UpcState {
  final List<UpcDb> upcDtoList;
  const UpcLoadedDtoState({this.upcDtoList});
  @override
  List<UpcDb> get props => upcDtoList;
}

class PushDetailsState extends UpcState {
  final UpcDb upcDto;

  const PushDetailsState({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

class ItemUpdatedState extends UpcState {
  final UpcDb upcDto;

  const ItemUpdatedState({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

class UpcErrorState extends UpcState {
  const UpcErrorState();
  @override
  List<UpcDb> get props => [];
}

class UpcEventStateBloc extends Bloc<UpcPageEvent, UpcState> {
  final UpcRepositoryInterface repository;

  int offSet = 0;
  int fetchQty = int.parse(Singleton.instance.prefs?.getString(SettingsFormBloc.pageSize) ?? '6') ?? 6;

  /// a user preference
  int currentPage = 0;
  int totalRowsInDb = 0;

  Future<void> _getOffset(UpcEvent upcEvent, int totalRows) async {
    debugPrint("start _getOffset");
    if (upcEvent is PageJumpEvent) {
      //ToDo: First scan fails to find upc
      //ToDo: Doesn't build when it jumps
      this.offSet = upcEvent?.offSet ?? 0;
      this.fetchQty = upcEvent?.fetchQty ?? 1;
      if (upcEvent?.code == null) {
        debugPrint("Null code detected on page jump.");
        return;
      }
      int index = await repository.getUpcDbIndex(upcEvent.code);
      this.currentPage = _calculatePageNumber(index);
      this.offSet = fetchQty * currentPage;
      debugPrint("Jumping to page ${this.currentPage}...");
    } else if (upcEvent is FirstPageEvent) {
      this.offSet = 0;
      this.currentPage = 1;
    } else if (upcEvent is NextPageEvent) {
      int tempOffSet = this.offSet;
      this.offSet = ((fetchQty * currentPage));
      if (totalRows == 0 || offSet >= totalRows) {
        this.offSet = tempOffSet;
        debugPrint("End of database reached. totalRowsInDb = $totalRows. No next Dto for you!");
        return;
      }
      this.currentPage++;
    } else if (upcEvent is PrevPageEvent) {
      this.currentPage -= 2;
      if (this.currentPage <= 0) {
        debugPrint("prevPage - calling firstPage");
        this.currentPage = 1;
        this.offSet = 0;
      } else {
        this.offSet = ((this.fetchQty * currentPage));
      }
    } else if (upcEvent is LastPageEvent) {
      /// Go to last page
      this.currentPage = _calculatePageNumber(totalRows);
      this.offSet = (this.fetchQty * currentPage);
      debugPrint("wjndbg: offset lastpage $offSet $currentPage");
    } else {
      // Error
      debugPrint("Error getting offSet");
    }
  }

  int _calculatePageNumber(int index) {
    if (index == null || index < 0) {
      debugPrint("Invalid index error. Failed to calculate page number.");
      return 1;
    }
    int pageNumber = ((index ~/ (this.fetchQty + 1)) + 1);
    if (pageNumber <= 0) {
      debugPrint("Unknown page number calculated error.");
      return 1;
    }
    return pageNumber;
  }

  UpcEventStateBloc(this.repository) : super(null);

  UpcState get initialState => UpcInitialDtoState();

  /// Page events map to state
  @override
  Stream<UpcState> mapEventToState(UpcPageEvent event) async* {
    if (event is ItemPagination) {
      UpcEvent upcEvent = event as UpcEvent;
      try {
        totalRowsInDb = await repository.count();

        _getOffset(upcEvent, totalRowsInDb);
        if (this.fetchQty == null) {
          debugPrint("Invalid pagination event occured");
          this.fetchQty = 6;
        }

        /// a user preference
        final upcList = await repository.fetchPageList(
            offSet: this.offSet, fetchQty: this.fetchQty, totalQty: totalRowsInDb);
        if (upcList != null) {
          yield UpcLoadedDtoState(upcDtoList: upcList);
        }
      } on Exception {
        debugPrint('UpcError!');
        yield UpcErrorState();
      }
    } else {
      switch (event.runtimeType) {
        case DecrementItemEvent:
          DecrementItemEvent evt = event as DecrementItemEvent;
          await repository.updateTotalByOne(evt.upcDto, -1);
          yield ItemUpdatedState(upcDto: evt.upcDto);
          break;
        case IncrementItemEvent:
          IncrementItemEvent evt = event as IncrementItemEvent;
          await repository.updateTotalByOne(evt.upcDto, 1);
          yield ItemUpdatedState(upcDto: evt.upcDto);
          break;
        case ZeroOutItemEvent:
          ZeroOutItemEvent evt = event as ZeroOutItemEvent;
          await repository.updateTotalByOne(evt.upcDto, -evt.upcDto.total);
          yield ItemUpdatedState(upcDto: evt.upcDto);
          break;
        case RefreshItemEvent:
          RefreshItemEvent evt = event as RefreshItemEvent;
          await repository.updateUpcDto(evt.upcDto);
          debugPrint('Updated UpcCode = ${evt.upcDto.code}');
          yield ItemUpdatedState(upcDto: evt.upcDto);
          break;
        case PushDetailsEvent:
          PushDetailsEvent evt = event as PushDetailsEvent;
          yield PushDetailsState(upcDto: evt.upcDto);
          break;
        default:
          debugPrint("Unknown event type error.");
          yield UpcErrorState();
          return;
      }
    }
  }

  ///Need to know if we have a upc code in the database - not just the in-memory list;
  Future<UpcDb> findUpcDbInDatabase(String code) async {
    return await repository.findUpcDtoInDatabase(code);
  }

  Future<int> countItemsScanned() async {
    return await repository.count();
  }

  Future<void> updateTotal(UpcDb upcDto, int value) async {
    await repository.updateTotalByOne(upcDto, value);
  }

  Future<void> addUpcToDevice(UpcDb upcDto, String goodImageUrl) async {
    await repository.addUpcToDevice(upcDto, goodImageUrl);
  }

  bool isValidUpcDbEntriesIndex(int index) {
    if (this.state.props.length == 0 || index >= this.state.props.length || this.state.props[index] == null) {
      return false;
    }
    return true;
  }

  UpcDb getUpcDtoAtIndex(int index) {
    if (!isValidUpcDbEntriesIndex(index)) {
      debugPrint('isValidUpcDbEntriesIndex - No item found in upc');
      return UpcDb(); //TODO does this need fields filled out?
    }
    UpcDb upcDto = state.props[index];
    return upcDto;
  }
}

void debugPrintItem(UpcDb upcDto, int index, String preText) {
  debugPrint(
      "Debug item: $preText= index=$index, upcTotal=${upcDto.total}, upcName=${upcDto.title}, upcCode=${upcDto.code}");
}
