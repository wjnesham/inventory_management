import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_bloc.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_state.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcDbHistory.dart';
import 'package:pantryfox/repository/upc_repository.dart';
import 'package:pantryfox/singleton.dart';

@immutable
abstract class DetailsBlocEvent {
  Stream<DetailsState> applyAsync({DetailsState currentState, DetailsBlocBloc bloc});
}

class CloseDetailsBlocEvent extends DetailsBlocEvent {
  @override
  Stream<DetailsState> applyAsync({DetailsState currentState, DetailsBlocBloc bloc}) async* {
    yield BuildDetailsBlocState();
  }
}

class LoadDetailsBlocEvent extends DetailsBlocEvent {
  final UpcDb upcDb;
  LoadDetailsBlocEvent(this.upcDb);

  @override
  Stream<DetailsState> applyAsync({DetailsState currentState, DetailsBlocBloc bloc}) async* {
    try {
      debugPrint("Getting histories from sqflite...");
      // Get histories, then check on the details page.
      List histories = await Singleton.instance.upcSqfliteDb.historyBean.findHistories(upcDb.code);
      if (histories == null) {
        debugPrint("You are out of this item");
        yield RetrievedHistoriesState(<UpcDbHistory>[]);
      } else {
        yield RetrievedHistoriesState(histories);
      }
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoadDetailsBlocEvent', error: _, stackTrace: stackTrace);
      yield ErrorDetailsBlocState(_?.toString());
    }
  }
}

class GetUpcHistoriesEvent extends DetailsBlocEvent {
  final List<UpcDbHistory> histories;
  GetUpcHistoriesEvent(this.histories);

  @override
  Stream<DetailsState> applyAsync({DetailsState currentState, DetailsBlocBloc bloc}) async* {
    try {
      // Check that there are histories
      if (histories.isEmpty) {
        debugPrint("You are out of this item");
      } else {
        yield RetrievedHistoriesState(histories);
      }
    } catch (_, stackTrace) {
      developer.log('$_', name: 'GetUpcHistoriesEvent', error: _, stackTrace: stackTrace);
      yield ErrorDetailsBlocState(_?.toString());
    }
  }
}

class RefreshItemDetailsEvent extends DetailsBlocEvent {
  final UpcDb upcDto;
  RefreshItemDetailsEvent(this.upcDto);

  @override
  Stream<DetailsState> applyAsync({DetailsState currentState, DetailsBlocBloc bloc}) async* {
    try {
      UpcRepository repository = UpcRepository();
      debugPrint("Submitting upcDto changes from details page...");
      yield SubmittingDetailsState();
      await repository.updateUpcDto(upcDto).then((value) => debugPrint('Updated UpcCode = ${upcDto.code}'));
      yield RefreshedItemDetailsState(upcDto);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'RefreshItemDetailsEvent', error: _, stackTrace: stackTrace);
      yield ErrorDetailsBlocState(_?.toString());
    }
  }
}
