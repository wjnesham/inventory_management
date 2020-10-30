import 'dart:async';
import 'dart:developer' as developer;

import 'package:pantryfox/bloc/history/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HistoryEvent {
  Stream<HistoryState> applyAsync({HistoryState currentState, HistoryBloc bloc});
}

class UnHistoryEvent extends HistoryEvent {
  @override
  Stream<HistoryState> applyAsync({HistoryState currentState, HistoryBloc bloc}) async* {
    yield UnHistoryState();
  }
}

class LoadHistoryEvent extends HistoryEvent {
  @override
  Stream<HistoryState> applyAsync({HistoryState currentState, HistoryBloc bloc}) async* {
    try {
      yield UnHistoryState();

      yield InHistoryState('Hello world');
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoadHistoryEvent', error: _, stackTrace: stackTrace);
      yield ErrorHistoryState(_?.toString());
    }
  }
}
