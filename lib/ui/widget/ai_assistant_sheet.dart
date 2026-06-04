import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readbox/domain/repositories/ai_repository.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/services/ai_chat_history_service.dart';

/// Bottom sheet AI Assistant dạng chat
/// Dùng: AiAssistantSheet.show(context, selectedText: text)
class AiAssistantSheet extends StatefulWidget {
  final String? initialText;
  final String ebookId;

  const AiAssistantSheet({super.key, this.initialText, required this.ebookId});

  static Future<void> show(
    BuildContext context, {
    required String ebookId,
    String? selectedText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AiAssistantSheet(ebookId: ebookId, initialText: selectedText),
    );
  }

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final _aiRepo = AiRepository();
  final _historyService = AiChatHistoryService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  final List<AiChatMessage> _messages = [];
  bool _isLoading = false;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _inputController.text = widget.initialText!.trim();
    }
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadHistory(widget.ebookId);
    if (mounted) {
      setState(() {
        _messages.addAll(history);
        _historyLoaded = true;
      });
      if (history.isNotEmpty) _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final query = _inputController.text.trim();
    if (query.isEmpty || _isLoading) return;

    final userMsg = AiChatMessage(
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final result = await _aiRepo.lookup(
        query: query,
        ebookId: widget.ebookId,
      );
      if (mounted) {
        final aiMsg = AiChatMessage(
          text: result,
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() => _messages.add(aiMsg));
        _scrollToBottom();
        await _historyService.saveHistory(widget.ebookId, _messages);
      }
    } catch (e) {
      if (mounted) {
        final errMsg = AiChatMessage(
          text: '${AppLocalizations.current.error}: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() => _messages.add(errMsg));
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: screenHeight * 0.82,
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(theme),
          const Divider(height: 1, thickness: 1),
          // Messages area
          Expanded(child: _buildMessageList(theme)),
          // Input bar
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Powered by Gemini',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const Spacer(),
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: () async {
                await _historyService.clearHistory(widget.ebookId);
                if (mounted) setState(() => _messages.clear());
              },
              icon: const Icon(Icons.delete_sweep_rounded),
              iconSize: 20,
              color: Colors.grey[500],
              tooltip: 'Xoá hội thoại',
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    if (!_historyLoaded) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_messages.isEmpty && !_isLoading) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          // Typing indicator
          return _buildTypingIndicator(theme);
        }
        final msg = _messages[index];
        return _buildMessageBubble(msg, theme);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.12),
                    theme.primaryColor.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.current.askToAiAnything,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.current.askToAiDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;
    final isError =
        !isUser && msg.text.startsWith(AppLocalizations.current.error);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _copyText(msg.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? theme.primaryColor
                              : isError
                              ? Colors.red[50]
                              : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border:
                          isError ? Border.all(color: Colors.red[200]!) : null,
                    ),
                    child: SelectableText(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color:
                            isUser
                                ? Colors.white
                                : isError
                                ? Colors.red[700]
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                // Copy action — chỉ hiện với tin nhắn AI, không hiện với lỗi
                if (!isUser && !isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    child: GestureDetector(
                      onTap: () => _copyText(msg.text),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.current.copy,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.current.copy_result),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return _TypingDot(delay: Duration(milliseconds: i * 200));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            enabled: _inputController.text.trim().isNotEmpty && !_isLoading,
            loading: _isLoading,
            primaryColor: theme.primaryColor,
            onTap: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// Nút gửi có animation
class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SendButton({
    required this.enabled,
    required this.loading,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient:
            enabled
                ? LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: enabled ? null : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Center(
            child:
                loading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: enabled ? Colors.white : Colors.grey[500],
                    ),
          ),
        ),
      ),
    );
  }
}

/// Dot animation cho typing indicator
class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder:
          (_, __) => Transform.translate(
            offset: Offset(0, _animation.value),
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
          ),
    );
  }
}
