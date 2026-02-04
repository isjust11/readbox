import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  final String? message;
  const BaseState({this.message});

  @override
  List<Object> get props => [];
}

class InitState extends BaseState {}

class LoadingState extends BaseState {}

class LoadedState<T> extends BaseState {
  final T data;
  final String message;
  final bool isLocalizeMessage;

  LoadedState(this.data, {this.message = "", this.isLocalizeMessage = true});
  
  LoadedState copyWith({
    T? data,
    String? message,
    bool? isLocalizeMessage,
  }) {
    return LoadedState(data ?? this.data, message: message ?? this.message, isLocalizeMessage: isLocalizeMessage ?? this.isLocalizeMessage);
  }
  
  @override
  List<Object> get props => [data as Object];
}

class ErrorState<T> extends BaseState {
  final T data;
  final timeEmit;
  final bool isLocalizeMessage;

  ErrorState(this.data, {this.isLocalizeMessage = true, this.timeEmit}) : assert(data != null);

  @override
  List<Object> get props => [data?.toString() ?? "", timeEmit];
}
class EmptyState extends BaseState {}