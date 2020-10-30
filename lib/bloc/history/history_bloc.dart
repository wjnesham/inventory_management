import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:pantryfox/bloc/history/index.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {

  HistoryBloc(HistoryState initialState) : super(initialState);

  @override
  Stream<HistoryState> mapEventToState(
    HistoryEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'HistoryBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
