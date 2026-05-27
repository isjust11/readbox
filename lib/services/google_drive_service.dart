import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:readbox/config/google_signin_config.dart';

/// Model đại diện cho một file trên Google Drive
class DriveFileInfo {
  final String id;
  final String name;
  final String mimeType;
  final int size;
  final DateTime? modifiedTime;
  final String? thumbnailLink;

  DriveFileInfo({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.modifiedTime,
    this.thumbnailLink,
  });

  /// Kiểm tra file có phải ebook không
  bool get isEbook {
    final ext = name.toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.epub') ||
        ext.endsWith('.mobi');
  }

  /// Lấy extension
  String get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Format kích thước file
  String get fileSizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Service để tương tác với Google Drive API
class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignInConfig.googleSignIn;

  /// Đăng nhập Google và lấy Drive API client.
  /// Drive scope là sensitive nên được xin riêng tại đây (lúc user dùng tính năng),
  /// không nhét vào flow đăng nhập để tránh cảnh báo "unverified app".
  static Future<drive.DriveApi?> _getDriveApi() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Không thể đăng nhập Google');
      }

      // Xin scope Drive (chỉ lần đầu user sẽ thấy consent screen Drive)
      const driveScope = GoogleSignInConfig.driveReadonlyScope;
      final hasScope = await _googleSignIn.requestScopes([driveScope]);
      if (!hasScope) {
        throw Exception('User đã từ chối quyền truy cập Google Drive');
      }

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw Exception('Không thể xác thực với Google Drive');
      }

      return drive.DriveApi(httpClient);
    } catch (e) {
      print('❌ Google Drive Auth Error: $e');
      rethrow;
    }
  }

  /// Liệt kê các file ebook trong folder
  static Future<List<DriveFileInfo>> listFilesInFolder(String folderId) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return [];

      final List<DriveFileInfo> files = [];
      String? pageToken;

      do {
        final fileList = await driveApi.files.list(
          q:
              "'$folderId' in parents and trashed = false and ("
              "mimeType = 'application/pdf' or "
              "mimeType = 'application/epub+zip' or "
              "name contains '.mobi' or "
              "name contains '.pdf' or "
              "name contains '.epub'"
              ")",
          spaces: 'drive',
          $fields:
              'nextPageToken, files(id, name, mimeType, size, modifiedTime, thumbnailLink)',
          pageSize: 100,
          pageToken: pageToken,
        );

        if (fileList.files != null) {
          for (final file in fileList.files!) {
            if (file.id != null && file.name != null) {
              files.add(
                DriveFileInfo(
                  id: file.id!,
                  name: file.name!,
                  mimeType: file.mimeType ?? '',
                  size: int.tryParse(file.size ?? '0') ?? 0,
                  modifiedTime: file.modifiedTime,
                  thumbnailLink: file.thumbnailLink,
                ),
              );
            }
          }
        }

        pageToken = fileList.nextPageToken;
      } while (pageToken != null);

      return files;
    } catch (e) {
      print('❌ Error listing Drive files: $e');
      rethrow;
    }
  }

  /// Tải file từ Google Drive về thiết bị
  /// Trả về đường dẫn file local sau khi tải xong
  static Future<String> downloadFile(String fileId, String fileName) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        throw Exception('Không thể kết nối Google Drive');
      }

      // Lấy directory lưu file
      final appDir = await getApplicationDocumentsDirectory();
      final driveDir = Directory('${appDir.path}/google_drive');
      if (!await driveDir.exists()) {
        await driveDir.create(recursive: true);
      }

      final filePath = '${driveDir.path}/$fileName';
      final file = File(filePath);

      // Nếu file đã tồn tại, trả về luôn
      if (await file.exists()) {
        return filePath;
      }

      // Tải file từ Drive
      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      await file.writeAsBytes(dataStore);
      return filePath;
    } catch (e) {
      print('❌ Error downloading Drive file: $e');
      rethrow;
    }
  }

  /// Kiểm tra folder ID có hợp lệ không
  static Future<bool> validateFolderId(String folderId) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final folder =
          await driveApi.files.get(folderId, $fields: 'id, name, mimeType')
              as drive.File;

      return folder.mimeType == 'application/vnd.google-apps.folder';
    } catch (e) {
      print('❌ Invalid folder ID: $e');
      return false;
    }
  }

  /// Trích xuất Folder ID từ URL Google Drive
  /// Hỗ trợ format: https://drive.google.com/drive/folders/<FOLDER_ID>
  static String? extractFolderIdFromUrl(String input) {
    // Nếu input đã là folder ID (không chứa dấu /)
    if (!input.contains('/') && !input.contains(' ')) {
      return input.trim();
    }

    // Thử trích xuất từ URL
    final regex = RegExp(r'folders/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(input);
    return match?.group(1);
  }

  /// Đăng xuất Google Drive
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
