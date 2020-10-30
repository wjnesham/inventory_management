import 'package:equatable/equatable.dart';
import 'package:pantryfox/model/upcDb.dart';

abstract class UpcEvent extends Equatable {
  const UpcEvent();
}

class FirstPageEvent extends UpcEvent implements ItemPagination, UpcPageEvent {
  final int offSet;
  final int fetchQty;

  const FirstPageEvent({this.offSet, this.fetchQty});

  @override
  List<Object> get props => [offSet, fetchQty];
}

class PageJumpEvent extends UpcEvent implements ItemPagination, UpcPageEvent {
  final int offSet;
  final int fetchQty;
  final String code;

  const PageJumpEvent(this.offSet, this.fetchQty, this.code);

  @override
  List<Object> get props => [offSet, fetchQty, code];
}

class PrevPageEvent extends UpcEvent implements ItemPagination, UpcPageEvent {
  final int offSet;
  final int fetchQty;

  const PrevPageEvent({this.offSet, this.fetchQty});

  @override
  List<Object> get props => [offSet, fetchQty];
}

class NextPageEvent extends UpcEvent implements ItemPagination, UpcPageEvent {
  final int offSet;
  final int fetchQty;

  const NextPageEvent({this.offSet, this.fetchQty});

  @override
  List<Object> get props => [offSet, fetchQty];
}

class PushDetailsEvent extends UpcEvent implements UpcPageEvent {
  final UpcDb upcDto;

  PushDetailsEvent(this.upcDto);

  @override
  List<Object> get props => [this.upcDto];
}

// LastPageEvent
class LastPageEvent extends UpcEvent implements ItemPagination, UpcPageEvent {
  final int offSet;
  final int fetchQty;

  const LastPageEvent({this.offSet, this.fetchQty});

  @override
  List<Object> get props => [offSet, fetchQty];
}

class IncrementItemEvent extends UpcEvent implements UpcPageEvent {
  final UpcDb upcDto;

  const IncrementItemEvent({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

class DecrementItemEvent extends UpcEvent implements UpcPageEvent {
  final UpcDb upcDto;

  const DecrementItemEvent({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

class ZeroOutItemEvent extends UpcEvent implements UpcPageEvent {
  final UpcDb upcDto;

  const ZeroOutItemEvent({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

class RefreshItemEvent extends UpcEvent implements UpcPageEvent {
  final UpcDb upcDto;

  const RefreshItemEvent({this.upcDto});

  @override
  List<Object> get props => [upcDto];
}

///
/// Marker Interfaces
class UpcPageEvent {}

class ItemPagination {}
