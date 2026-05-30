import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

/// Loại section trên màn Discover.
enum DiscoverSection { newest, popular, recommended }

/// State snapshot cho từng section: dùng riêng để UI có thể rebuild
/// độc lập (1 section lỗi không che mất 2 section còn lại).
class DiscoverSectionState {
  final bool isLoading;
  final List<BookModel> books;
  final String? error;

  const DiscoverSectionState({
    this.isLoading = false,
    this.books = const [],
    this.error,
  });

  DiscoverSectionState copyWith({
    bool? isLoading,
    List<BookModel>? books,
    String? error,
    bool clearError = false,
  }) {
    return DiscoverSectionState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Snapshot tổng hợp cho toàn màn Discover.
class DiscoverState extends BaseState {
  final DiscoverSectionState newest;
  final DiscoverSectionState popular;
  final DiscoverSectionState recommended;

  const DiscoverState({
    this.newest = const DiscoverSectionState(),
    this.popular = const DiscoverSectionState(),
    this.recommended = const DiscoverSectionState(),
  });

  DiscoverState copyWith({
    DiscoverSectionState? newest,
    DiscoverSectionState? popular,
    DiscoverSectionState? recommended,
  }) {
    return DiscoverState(
      newest: newest ?? this.newest,
      popular: popular ?? this.popular,
      recommended: recommended ?? this.recommended,
    );
  }

  @override
  List<Object> get props => [newest, popular, recommended];
}

class DiscoverCubit extends Cubit<DiscoverState> {
  final BookRepository repository;
  final int defaultSize;

  DiscoverCubit({required this.repository, this.defaultSize = 10})
      : super(const DiscoverState());

  /// Load song song cả 3 section. Mỗi section catch lỗi riêng để không
  /// làm gãy toàn màn.
  Future<void> loadAll({int? size}) async {
    final s = size ?? defaultSize;
    await Future.wait([
      _load(DiscoverSection.newest, size: s),
      _load(DiscoverSection.popular, size: s),
      _load(DiscoverSection.recommended, size: s),
    ]);
  }

  Future<void> refreshSection(DiscoverSection section, {int? size}) async {
    await _load(section, size: size ?? defaultSize);
  }

  Future<void> _load(DiscoverSection section, {required int size}) async {
    _emitSection(section, (s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final books = await _fetch(section, size: size);
      _emitSection(
        section,
        (s) => s.copyWith(isLoading: false, books: books, clearError: true),
      );
    } catch (e) {
      _emitSection(
        section,
        (s) => s.copyWith(
          isLoading: false,
          error: BlocUtils.getMessageError(e),
        ),
      );
    }
  }

  Future<List<BookModel>> _fetch(
    DiscoverSection section, {
    required int size,
  }) {
    switch (section) {
      case DiscoverSection.newest:
        return repository.getDiscoverNewest(page: 1, size: size);
      case DiscoverSection.popular:
        return repository.getDiscoverPopular(page: 1, size: size);
      case DiscoverSection.recommended:
        return repository.getDiscoverRecommended(page: 1, size: size);
    }
  }

  void _emitSection(
    DiscoverSection section,
    DiscoverSectionState Function(DiscoverSectionState current) update,
  ) {
    switch (section) {
      case DiscoverSection.newest:
        emit(state.copyWith(newest: update(state.newest)));
        break;
      case DiscoverSection.popular:
        emit(state.copyWith(popular: update(state.popular)));
        break;
      case DiscoverSection.recommended:
        emit(state.copyWith(recommended: update(state.recommended)));
        break;
    }
  }
}
