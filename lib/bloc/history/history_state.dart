import 'package:equatable/equatable.dart';

abstract class HistoryState extends Equatable {

  final List propss;
  HistoryState([this.propss]);

  @override
  List<Object> get props => (propss ?? []);
}

/// UnInitialized
class UnHistoryState extends HistoryState {

  UnHistoryState();

  @override
  String toString() => 'UnHistoryState';
}

/// Initialized
class InHistoryState extends HistoryState {
  final String hello;

  InHistoryState(this.hello) : super([hello]);

  @override
  String toString() => 'InHistoryState $hello';

}

class ErrorHistoryState extends HistoryState {
  final String errorMessage;

  ErrorHistoryState(this.errorMessage): super([errorMessage]);
  
  @override
  String toString() => 'ErrorHistoryState';
}
