import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/ai_assistant_sheet.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:readbox/utils/tts_lock_screen_controller.dart';
import 'package:share_plus/share_plus.dart';

class EpubViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String? bookId;
  final String? userIdCreate;

  const EpubViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    this.bookId,
    this.userIdCreate,
  });

  @override
  EpubViewerScreenState createState() => EpubViewerScreenState();
}

class EpubViewerScreenState extends State<EpubViewerScreen> {
  late EpubController _epubController;
  bool _isLoading = true;
  String? _error;
  bool _isLocal = false;
  Uint8List? _epubBytes;
  Map<String, bool>? _actionStatus = {};
  bool _isVisibleToolAction = false;
  bool showToolbar = true;
  bool showNavigationBar = true;
  String? actionToolbar = '';

  // TTS related
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isReadingContinuous = false;
  final ValueNotifier<(int, int)> _ttsWordProgressNotifier = ValueNotifier((
    0,
    0,
  ));

  final Dio _dio = Dio();
  UserModel? _currentUser;
  late UserSubscriptionModel? _userSubscription;

  bool get isEnableAction => _error == null;
  bool get isProPlan => !(_userSubscription?.isFree ?? true);
  bool get isOwner => _currentUser?.id == widget.userIdCreate;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUserDataSettings();
    _initController();

    context.read<SubscriptionPlanCubit>().checkUsage();
    context.read<SubscriptionPlanCubit>().stream.listen((state) {
      if (state is LoadedState<Map<String, bool>> && mounted) {
        setState(() {
          _actionStatus = state.data;
        });
      }
    });

    if (widget.bookId != null) {
      _loadReadingProgress();
    }
  }

  void _loadCurrentUser() {
    final user = context.read<AppCubit>().getUser();
    if (user != null) {
      _currentUser = user;
    }
  }

  Future<void> _loadUserDataSettings() async {
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    if (mounted) {
      setState(() {
        showNavigationBar = !hideNavigationBar;
      });
    }
  }

  Future<void> _initController() async {
    final file = File(widget.fileUrl);
    _isLocal = await file.exists();

    if (_isLocal) {
      _epubBytes = await file.readAsBytes();
      _epubController = EpubController(
        document: EpubDocument.openData(_epubBytes!),
      );
    } else {
      final networkUrl =
          widget.fileUrl.startsWith('http')
              ? widget.fileUrl
              : '${ApiConstant.apiHostStorage}${widget.fileUrl}';

      // Wait, we should download it first if it's network.
      await _downloadAndLoadEpub(networkUrl);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndLoadEpub(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      _epubBytes = Uint8List.fromList(response.data!);
      _epubController = EpubController(
        document: EpubDocument.openData(_epubBytes!),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _loadReadingProgress() {
    // Implement loading progress if needed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userSubscription = context.watch<UserSubscriptionCubit>().userSubscription;
  }

  @override
  void dispose() {
    _ttsService.stop();
    TtsLockScreenController.instance.stop();
    _epubController.dispose();
    _ttsWordProgressNotifier.dispose();
    _dio.close();
    super.dispose();
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'ai_assistant':
        if (!isProPlan) {
          Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
          return;
        }
        AiAssistantSheet.show(context);
        break;
      case 'search':
        actionToolbar = 'search';
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        break;
      case 'download':
        if (!isProPlan && !(_actionStatus?['canUseDownload'] ?? false)) {
          Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
          return;
        }
        _downloadAndSaveEpub();
        break;
      case 'share':
        _shareEbook();
        break;
      case 'read_continuous_ebook':
        if (!isProPlan) {
          Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
          return;
        }
        _readContinuousEbook();
        break;
    }
  }

  Future<void> _downloadAndSaveEpub() async {
    try {
      if (_epubBytes == null) return;

      final Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory(path.join(appDir.path, 'Downloads'));
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = path.basename(widget.fileUrl);
      final file = File(path.join(downloadsDir.path, fileName));
      await file.writeAsBytes(_epubBytes!);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.tools_saved_successfully,
          snackBarType: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.tools_save_failed,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _shareEbook() async {
    try {
      if (_epubBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(widget.fileUrl);
      final tempFile = File(path.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(_epubBytes!);

      await SharePlus.instance.share(
        ShareParams(
          text: AppLocalizations.current.pdf_share_text(widget.title),
          subject: widget.title,
          files: [XFile(tempFile.path)],
        ),
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_share_error(e.toString()),
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _readContinuousEbook() async {
    setState(() {
      _isReadingContinuous = true;
    });
    AppSnackBar.show(
      context,
      message: "Continuous reading for EPUB is coming soon",
      snackBarType: SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isVisibleToolAction ? _buildToolAppBar() : _buildDefaultAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : EpubView(
                controller: _epubController,
                onDocumentLoaded: (document) {},
                onExternalLinkPressed: (link) {},
              ),
    );
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                _buildMenuItem(
                  'ai_assistant',
                  Icons.auto_awesome,
                  AppLocalizations.current.ai_assistant,
                  Colors.purple,
                  isPro: true,
                ),
                _buildMenuItem(
                  'search',
                  Icons.search,
                  AppLocalizations.current.search,
                  Colors.blue,
                ),
                _buildMenuItem(
                  'read_continuous_ebook',
                  Icons.record_voice_over,
                  AppLocalizations.current.pdf_read_ebook,
                  Colors.orange,
                  isPro: true,
                ),
                _buildMenuItem(
                  'download',
                  Icons.download,
                  AppLocalizations.current.tools_save_as_pdf,
                  Colors.green,
                ),
                _buildMenuItem(
                  'share',
                  Icons.share,
                  AppLocalizations.current.pdf_share,
                  Colors.blue,
                ),
              ],
        ),
      ],
    );
  }

  AppBar _buildToolAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => _isVisibleToolAction = false),
      ),
      title:
          actionToolbar == 'search'
              ? TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.current.search,
                ),
                onSubmitted: (value) {},
              )
              : Text(widget.title),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color, {
    bool? isEnabled = true,
    bool? isPro = false,
  }) {
    Color iconColor = color;
    if (value == 'read_continuous_ebook' && _isReadingContinuous) {
      iconColor = Colors.red;
    }
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isEnabled == true ? iconColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isEnabled == true ? null : Colors.grey),
          ),
          if (isPro == true && !isProPlan) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.current.pro,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
