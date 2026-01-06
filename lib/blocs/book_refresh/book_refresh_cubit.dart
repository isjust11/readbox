import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit quản lý việc refresh danh sách sách toàn app
/// Khi có sự thay đổi (thêm/sửa/xóa sách), emit state để các màn hình refresh
class BookRefreshCubit extends Cubit<int> {
  BookRefreshCubit() : super(0);

  /// Gọi method này khi cần refresh danh sách sách
  /// Ví dụ: sau khi thêm mới, cập nhật, hoặc xóa sách
  void notifyBookListChanged() {
    emit(state + 1); // Emit state mới để trigger rebuild
  }

  /// Reset về trạng thái ban đầu
  void reset() {
    emit(0);
  }
}

