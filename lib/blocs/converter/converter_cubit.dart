import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/datasources/remote/converter_remote_data_source.dart';

class ConverterCubit extends Cubit<BaseState> {
  final ConverterRemoteDataSource _converterRemoteDataSource;

  ConverterCubit(this._converterRemoteDataSource) : super(InitState());

  File? _selectedFile;
  String? _outputPath;
  double _uploadProgress = 0.0;

  File? get selectedFile => _selectedFile;
  String? get outputPath => _outputPath;
  double get uploadProgress => _uploadProgress;

  /// Select file for conversion
  void selectFile(File file) {
    _selectedFile = file;
    _outputPath = null;
    _uploadProgress = 0.0;
    emit(LoadedState(file, message: 'File đã được chọn'));
  }

  /// Reset selected file and output
  void resetFile() {
    _selectedFile = null;
    _outputPath = null;
    _uploadProgress = 0.0;
    emit(InitState());
  }

  /// Convert Word to PDF
  Future<void> convertWordToPdf() async {
    if (_selectedFile == null) {
      emit(ErrorState('Vui lòng chọn file trước'));
      return;
    }

    try {
      emit(LoadingState());
      _uploadProgress = 0.0;

      // Call API to convert
      final response = await _converterRemoteDataSource.convertWordToPdf(
        file: _selectedFile!,
        onProgress: (progress) {
          _uploadProgress = progress;
          // Emit loading state with progress update
          emit(LoadingState());
        },
      );

      // Save PDF to local storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _selectedFile!.path.split(RegExp(r'[/\\]')).last;
      final outputFileName = fileName.replaceAll(
        RegExp(r'\.(doc|docx)$', caseSensitive: false),
        '.pdf',
      );
      final outputPath = '${directory.path}/$outputFileName';
      
      final outputFile = File(outputPath);

      await outputFile.writeAsBytes(response);

      _outputPath = outputPath;
      _uploadProgress = 1.0;

      emit(LoadedState(
        outputPath,
        message: 'Chuyển đổi thành công',
      ));
    } catch (e) {
      _uploadProgress = 0.0;
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Reset state
  void reset() {
    _selectedFile = null;
    _outputPath = null;
    _uploadProgress = 0.0;
    emit(InitState());
  }
}
