import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/services/search_history_service.dart';

class SearchRecentPanel extends StatefulWidget {
  final Function(String) onSearchSelected;
  final bool isVisible;

  const SearchRecentPanel({
    super.key,
    required this.onSearchSelected,
    this.isVisible = false,
  });

  @override
  State<SearchRecentPanel> createState() => _SearchRecentPanelState();
}

class _SearchRecentPanelState extends State<SearchRecentPanel> {
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  List<String> _searchHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSearchHistory();
    });
  }

  @override
  void didUpdateWidget(covariant SearchRecentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _loadSearchHistory();
    }
  }

  Future<void> _loadSearchHistory() async {
    if (mounted) {
      setState(() => _isLoading = true);
      final history = await _searchHistoryService.getSearchHistory();
      if (mounted) {
        setState(() {
          _searchHistory = history;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeSearchTerm(String term) async {
    await _searchHistoryService.removeSearchTerm(term);
    await _loadSearchHistory();
  }

  Future<void> _clearAllHistory() async {
    await _searchHistoryService.clearHistory();
    await _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    if(_searchHistory.isEmpty) return const SizedBox.shrink();
    if (!widget.isVisible) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.current.recent_searches,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_searchHistory.isNotEmpty)
                  GestureDetector(
                    onTap: _clearAllHistory,
                    child:                     Text(
                      AppLocalizations.current.clear_all,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_searchHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.search_outlined,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.current.no_recent_searches,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            // Search history list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchHistory.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final term = _searchHistory[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  dense: true,
                  leading: Icon(
                    Icons.history,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  title: Text(
                    term,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => _removeSearchTerm(term),
                  ),
                  onTap: () => widget.onSearchSelected(term),
                );
              },
            ),
        ],
      ),
    );
  }
}