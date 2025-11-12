import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_bloc/base_state.dart';

const int DEFAULT_PAGE_SIZE = 12;

abstract class BaseListCubit<T> extends Cubit<T> {
  int _pageNum = 1;
  dynamic _refresh;
  bool _endOfPage = false;

  BaseListCubit(T state) : super(state);

  void increasePageNum() {
    _pageNum++;
  }

  void setEndOfPage() {
    _endOfPage = true;
  }

  void setDefaultConfig(refresh) {
    _pageNum = 1;
    _endOfPage = false;
    if (refresh != null) {
      this._refresh = refresh;
    }
  }

  bool canLoadMore() {
    if (_endOfPage) {
      _refresh.loadComplete();
      _refresh.refreshCompleted();
      return false;
    }
    return true;
  }

  void finishLoad() {
    if (_refresh != null) {
      _refresh.loadComplete();
      _refresh.refreshCompleted();
    }
  }

  Map getDataRequest(Map<String, dynamic> mapRequest) {
    Map<String, dynamic> map = {
      "pageNum": _pageNum,
      "pageSize": DEFAULT_PAGE_SIZE,
    };
    map.addAll(mapRequest);
    return map;
  }

  List<C> getListDataCurrent<C>() {
    if (state is LoadedState && (state as LoadedState).data != null) {
      return (state as LoadedState).data;
    }
    return [];
  }
}
