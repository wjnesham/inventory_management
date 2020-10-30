import 'package:equatable/equatable.dart';
import 'package:pantryfox/model/upcDb.dart';
import 'package:pantryfox/model/upcDbHistory.dart';

abstract class DetailsState extends Equatable {
  final List propss;
  DetailsState([this.propss]);

  @override
  List<Object> get props => (propss ?? []);
}

/// Close Details
class BuildDetailsBlocState extends DetailsState {
  BuildDetailsBlocState();

  @override
  String toString() => 'BuildDetailsBlocState called';
}

/// Initialized
class InitDetailsState extends DetailsState {
  final UpcDb upcDb;

  InitDetailsState(this.upcDb) : super([upcDb]);

  @override
  String toString() => 'InitDetailsBlocState with code = ${upcDb.code}';
}

class ErrorDetailsBlocState extends DetailsState {
  final String errorMessage;

  ErrorDetailsBlocState(this.errorMessage) : super([errorMessage]);

  @override
  String toString() => 'ErrorDetailsBlocState';
}

class RetrievedHistoriesState extends DetailsState {
  final List<UpcDbHistory> histories;
  RetrievedHistoriesState(this.histories);

  @override
  List<Object> get props => [histories];

  @override
  String toString() => 'RetrievedHistoriesState histories for code = ${histories.first.historyKey}';
}

class SubmittingDetailsState extends DetailsState {
  @override
  String toString() => 'SubmittingDetailsState loading...';
}

class RefreshedItemDetailsState extends DetailsState {
  final UpcDb upcDto;
  RefreshedItemDetailsState(this.upcDto) : super([upcDto.code]);

  @override
  String toString() => 'RefreshedItemDetailsState for code = ${upcDto.code}';
}
