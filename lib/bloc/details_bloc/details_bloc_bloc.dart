import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_event.dart';
import 'package:pantryfox/bloc/details_bloc/details_bloc_state.dart';

class DetailsBlocBloc extends Bloc<DetailsBlocEvent, DetailsState> {
  DetailsBlocBloc(DetailsState initialState) : super(initialState);

  @override
  Stream<DetailsState> mapEventToState(DetailsBlocEvent event) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'DetailsBlocBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
