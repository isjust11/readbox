import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object> get props => [];
}

class InitState extends BaseState {}

class LoadingState extends BaseState {}

class LoadedState<T> extends BaseState {
  final T data;
  final String msgError;
  final timeEmit;
  final bool isLocalizeMessage;

  LoadedState(this.data, {this.msgError = "", this.timeEmit, this.isLocalizeMessage = true});

  @override
  List<Object> get props => [data as Object, timeEmit ?? ""];
}

class ErrorState<T> extends BaseState {
  final T data;
  final timeEmit;
  final bool isLocalizeMessage;

  ErrorState(this.data, {this.isLocalizeMessage = true, this.timeEmit}) : assert(data != null);

  @override
  List<Object> get props => [data?.toString() ?? "", timeEmit];
}
