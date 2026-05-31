import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/tts_lock_screen_controller.dart';

/// Singleton state cho cụm nút floating toàn app:
/// - Vị trí được giữ nguyên qua các màn (chỉ trong session).
/// - Mỗi loại nút có flag "đã ẩn cho session" (drag-to-close).
/// - Tự reset visibility khi state nguồn (đang đọc / đang TTS) chuyển sang
///   active mới, tránh user bị "kẹt" sau khi đã đóng.
class FloatingActionsController {
  FloatingActionsController._();
  static final FloatingActionsController instance =
      FloatingActionsController._();

  /// `null` = chưa kéo lần nào, dùng vị trí mặc định (góc dưới-phải).
  final ValueNotifier<Offset?> position = ValueNotifier<Offset?>(null);

  /// Flag tạm ẩn (do user kéo vào vùng close).
  final ValueNotifier<bool> continueReadingDismissed = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> ttsDismissed = ValueNotifier<bool>(false);

  /// Callback chuyển trang khi tap nút Continue Reading.
  /// Set bởi MainScreen để tận dụng logic open book sẵn có.
  void Function(BuildContext context, UserInteractionModel interaction)?
  onContinueReadingPressed;

  /// Callback chuyển trang khi tap nút TTS (mở lại book đang đọc nền).
  void Function(BuildContext context, TtsBackgroundInfo info)? onTtsPressed;

  void resetContinueReadingVisibility() {
    if (continueReadingDismissed.value) {
      continueReadingDismissed.value = false;
    }
  }

  void resetTtsVisibility() {
    if (ttsDismissed.value) {
      ttsDismissed.value = false;
    }
  }
}

/// Cụm icon-only FAB (Continue Reading + TTS background) hiển thị trên mọi
/// màn dùng `BaseScreen`. Các nút có thể:
/// - Kéo thả tự do trong phạm vi màn hình.
/// - Snap về sát mép trái/phải sau khi nhả tay.
/// - Kéo vào vùng "X" ở giữa-dưới để ẩn cho session hiện tại.
class GlobalFloatingActions extends StatefulWidget {
  final bool showContinueReadingFab;
  const GlobalFloatingActions({super.key, this.showContinueReadingFab = false});

  @override
  State<GlobalFloatingActions> createState() => _GlobalFloatingActionsState();
}

class _GlobalFloatingActionsState extends State<GlobalFloatingActions> {
  static const double _fabSize = 52;
  static const double _gap = 10;
  static const double _edgePadding = 12;
  static const double _closeZoneSize = 84;
  static const double _closeZoneBottomMargin = 32;

  Offset? _position;
  bool _isDragging = false;
  bool _isOverCloseZone = false;
  TtsBackgroundInfo? _lastTtsActiveInfo;
  int _lastReadingCount = 0;

  @override
  void initState() {
    super.initState();
    _position = FloatingActionsController.instance.position.value;
    FloatingActionsController.instance.position.addListener(
      _onPositionExternal,
    );
    FloatingActionsController.instance.continueReadingDismissed.addListener(
      _onAnyControllerChange,
    );
    FloatingActionsController.instance.ttsDismissed.addListener(
      _onAnyControllerChange,
    );
    TtsLockScreenController.instance.backgroundInfo.addListener(_onTtsChange);
  }

  @override
  void dispose() {
    FloatingActionsController.instance.position.removeListener(
      _onPositionExternal,
    );
    FloatingActionsController.instance.continueReadingDismissed.removeListener(
      _onAnyControllerChange,
    );
    FloatingActionsController.instance.ttsDismissed.removeListener(
      _onAnyControllerChange,
    );
    TtsLockScreenController.instance.backgroundInfo.removeListener(
      _onTtsChange,
    );
    super.dispose();
  }

  void _onPositionExternal() {
    if (!mounted) return;
    setState(
      () => _position = FloatingActionsController.instance.position.value,
    );
  }

  void _onAnyControllerChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _onTtsChange() {
    final info = TtsLockScreenController.instance.backgroundInfo.value;
    // Khi xuất hiện session TTS active mới → reset cờ ẩn để người dùng vẫn
    // thấy mini-player thay vì bị giấu vĩnh viễn.
    if (info.isActive && _lastTtsActiveInfo?.bookId != info.bookId) {
      FloatingActionsController.instance.resetTtsVisibility();
    }
    _lastTtsActiveInfo = info.isActive ? info : null;
    if (mounted) setState(() {});
  }

  Offset _defaultPosition(Size screen, double clusterHeight, EdgeInsets safe) {
    return Offset(
      screen.width - _fabSize - _edgePadding,
      screen.height - clusterHeight - safe.bottom - 90,
    );
  }

  Offset _clampPosition(
    Offset pos,
    Size screen,
    double clusterHeight,
    EdgeInsets safe,
  ) {
    final maxX = screen.width - _fabSize - _edgePadding;
    final maxY = screen.height - clusterHeight - safe.bottom - _edgePadding;
    return Offset(
      pos.dx.clamp(_edgePadding, maxX).toDouble(),
      pos.dy.clamp(safe.top + _edgePadding, maxY).toDouble(),
    );
  }

  Rect _closeZoneRect(Size screen, EdgeInsets safe) {
    final left = (screen.width - _closeZoneSize) / 2;
    final top =
        screen.height - safe.bottom - _closeZoneBottomMargin - _closeZoneSize;
    return Rect.fromLTWH(left, top, _closeZoneSize, _closeZoneSize);
  }

  bool _intersectsCloseZone(Offset pos, double clusterHeight, Rect zone) {
    final fabRect = Rect.fromLTWH(pos.dx, pos.dy, _fabSize, clusterHeight);
    return fabRect.overlaps(zone);
  }

  void _onPanStart(DragStartDetails _) {
    HapticFeedback.lightImpact();
    setState(() {
      _isDragging = true;
      _isOverCloseZone = false;
    });
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screen,
    double clusterHeight,
    EdgeInsets safe,
  ) {
    final next =
        (_position ?? _defaultPosition(screen, clusterHeight, safe)) +
        details.delta;
    final clamped = _clampPosition(next, screen, clusterHeight, safe);
    final closeZone = _closeZoneRect(screen, safe);
    final overClose = _intersectsCloseZone(clamped, clusterHeight, closeZone);
    if (overClose != _isOverCloseZone) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _position = clamped;
      _isOverCloseZone = overClose;
    });
  }

  void _onPanEnd(
    bool hasReading,
    bool hasTts,
    Size screen,
    double clusterHeight,
    EdgeInsets safe,
  ) {
    if (_isOverCloseZone) {
      HapticFeedback.mediumImpact();
      // Ẩn mọi nút đang hiển thị cho session.
      if (hasReading) {
        FloatingActionsController.instance.continueReadingDismissed.value =
            true;
      }
      if (hasTts) {
        FloatingActionsController.instance.ttsDismissed.value = true;
      }
    } else if (_position != null) {
      // Snap về mép trái/phải gần nhất.
      final centerX = _position!.dx + _fabSize / 2;
      final dxSnapped =
          centerX < screen.width / 2
              ? _edgePadding
              : screen.width - _fabSize - _edgePadding;
      final snapped = Offset(dxSnapped, _position!.dy);
      _position = _clampPosition(snapped, screen, clusterHeight, safe);
      FloatingActionsController.instance.position.value = _position;
    }
    setState(() {
      _isDragging = false;
      _isOverCloseZone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TtsBackgroundInfo>(
      valueListenable: TtsLockScreenController.instance.backgroundInfo,
      builder: (context, ttsInfo, _) {
        return BlocBuilder<UserInteractionCubit, BaseState>(
          buildWhen:
              (prev, curr) => curr is LoadedState<List<UserInteractionModel>>,
          builder: (context, state) {
            final readingBooks =
                state is LoadedState<List<UserInteractionModel>>
                    ? state.data
                    : const <UserInteractionModel>[];

            // Khi có thêm sách mới đang đọc → reset cờ ẩn để hiển thị lại.
            if (readingBooks.length > _lastReadingCount) {
              FloatingActionsController.instance
                  .resetContinueReadingVisibility();
            }
            _lastReadingCount = readingBooks.length;

            final showReading =
                widget.showContinueReadingFab &&
                readingBooks.isNotEmpty &&
                !FloatingActionsController
                    .instance
                    .continueReadingDismissed
                    .value;
            final showTts =
                ttsInfo.isActive &&
                !FloatingActionsController.instance.ttsDismissed.value;

            if (!showReading && !showTts) return const SizedBox.shrink();

            final fabCount = (showReading ? 1 : 0) + (showTts ? 1 : 0);
            final clusterHeight =
                fabCount * _fabSize +
                (fabCount - 1).clamp(0, 1).toDouble() * _gap;

            final media = MediaQuery.of(context);
            final screen = media.size;
            final safe = media.padding;
            final pos =
                _position == null
                    ? _defaultPosition(screen, clusterHeight, safe)
                    : _clampPosition(_position!, screen, clusterHeight, safe);

            return Stack(
              children: [
                if (_isDragging) _buildCloseZone(_closeZoneRect(screen, safe)),
                Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate:
                        (d) => _onPanUpdate(d, screen, clusterHeight, safe),
                    onPanEnd:
                        (_) => _onPanEnd(
                          showReading,
                          showTts,
                          screen,
                          clusterHeight,
                          safe,
                        ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showTts) ...[
                            _TtsFab(info: ttsInfo),
                            if (showReading) const SizedBox(height: _gap),
                          ],
                          if (showReading)
                            _ContinueReadingFab(
                              latestInteraction: readingBooks.first,
                              count: readingBooks.length,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCloseZone(Rect rect) {
    final color =
        _isOverCloseZone
            ? Colors.redAccent
            : Colors.black.withValues(alpha: 0.55);
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _isOverCloseZone ? 1.12 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _ContinueReadingFab extends StatelessWidget {
  const _ContinueReadingFab({
    required this.latestInteraction,
    required this.count,
  });

  final UserInteractionModel latestInteraction;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: AppLocalizations.current.continue_reading,
      button: true,
      child: _CircleFab(
        backgroundColor: theme.colorScheme.primary,
        badge: count > 1 ? count.toString() : null,
        onTap: () {
          final cb =
              FloatingActionsController.instance.onContinueReadingPressed;
          if (cb != null) {
            cb(context, latestInteraction);
          }
        },
        child: Icon(
          Icons.menu_book_rounded,
          color: theme.colorScheme.onPrimary,
          size: 26,
        ),
      ),
    );
  }
}

class _TtsFab extends StatelessWidget {
  const _TtsFab({required this.info});
  final TtsBackgroundInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = info.isPlaying;
    return GestureDetector(
      onLongPress: () {
        TtsLockScreenController.instance.stop();
      },
      child: Semantics(
        label:
            info.bookTitle.isNotEmpty
                ? info.bookTitle
                : AppLocalizations.current.continue_reading,
        button: true,
        child: _CircleFab(
          backgroundColor: theme.colorScheme.tertiary,
          pulsing: isPlaying,
          onTap: () async {
            // Tap → pause/resume; Long-press → stop session (xử lý trên).
            if (isPlaying) {
              await TtsLockScreenController.instance.pauseFromUi();
            } else {
              await TtsLockScreenController.instance.resumeFromUi();
            }
          },
          onDoubleTap: () {
            // Double-tap → mở lại màn book đang đọc nền (nếu có).
            final cb = FloatingActionsController.instance.onTtsPressed;
            if (cb != null) cb(context, info);
          },
          child:
              isPlaying
                  ? Image.asset(
                    Assets.images.audioPlay.path,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    color: theme.colorScheme.onTertiary,
                    colorBlendMode: BlendMode.srcIn,
                  )
                  : Icon(
                    Icons.play_arrow_rounded,
                    color: theme.colorScheme.onTertiary,
                    size: 28,
                  ),
        ),
      ),
    );
  }
}

class _CircleFab extends StatefulWidget {
  const _CircleFab({
    required this.backgroundColor,
    required this.child,
    required this.onTap,
    this.onDoubleTap,
    this.badge,
    this.pulsing = false,
  });

  final Color backgroundColor;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final String? badge;
  final bool pulsing;

  @override
  State<_CircleFab> createState() => _CircleFabState();
}

class _CircleFabState extends State<_CircleFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.pulsing) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _CircleFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulsing && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse =
            widget.pulsing ? 1 + (_pulseController.value * 0.06) : 1.0;
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: widget.backgroundColor.withValues(alpha: 0.45),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.78),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.backgroundColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: widget.child,
                  ),
                ),
                if (widget.badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
