import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/entities/entities.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/utils.dart';

/// Màn "Khám phá" mới: hiển thị 3 section (Ebook mới, Yêu thích, Gợi ý)
/// dưới dạng horizontal list. Mỗi section có nút "Xem tất cả" điều hướng
/// sang `AllEbooksScreen` với filter tương ứng.
import 'package:readbox/ui/widget/app_widgets/book_options_bottom_sheet.dart';
import 'package:readbox/ui/widgets/banner_ad_widget.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  UserModel? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getUnreadCount();
      context.read<DiscoverCubit>().loadAll();
      _loadUserReadingBooks();
    });
  }

  Future<void> _loadUserInfo() async {
    final user = await SecureStorageService().getUserInfo();
    if (user != null && mounted) {
      context.read<AppCubit>().setUser(user);
      setState(() => _userInfo = user);
    }
  }

  Future<void> _loadUserReadingBooks() async {
    await context.read<UserInteractionCubit>().getMyInteractions(query: {
      'page': 1,
      'limit': 10,
      'interactionType': InteractionType.reading.name,
      'targetType': InteractionTarget.book.name,
    });
  }

  Future<void> _onRefresh() => context.read<DiscoverCubit>().loadAll();

  void _openBook(BookModel book, {BookFileEntity? selectedFile}) {
    final String targetUrl = selectedFile?.fileUrl ?? book.fileUrl ?? '';
    final targetType = selectedFile != null 
        ? (selectedFile.format?.toLowerCase() == 'pdf' ? BookType.pdf : BookType.epub)
        : book.fileType;

    if (targetUrl.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.file_ebook_not_found,
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    final route = targetType == BookType.epub
        ? Routes.epubViewerScreen
        : Routes.pdfViewerScreen;
        
    final bookToOpen = BookModel.fromJson(book.toJson());
    bookToOpen.fileUrl = targetUrl;
    bookToOpen.fileType = targetType;

    Navigator.pushNamed(context, route, arguments: bookToOpen);
  }

  void _openAllEbooks({FilterType? filter}) {
    Navigator.pushNamed(
      context,
      Routes.allEbooksScreen,
      arguments: filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BaseScreen<DiscoverCubit>(
      colorBg: colorScheme.surface,
      autoHandleState: false,
      customAppBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
        title: Text(
          AppLocalizations.current.home,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          _buildNotificationButton(),
        ],
      ),
      drawer: AppDrawer(
        user: _userInfo,
        // Highlight item "Home" khi user đang ở DiscoverScreen.
        currentFilter: 'home',
        onSelected: (filter, title) {
          // Home → đã ở Discover, chỉ refresh 3 section, không điều hướng.
          if (filter == 'home') {
            context.read<DiscoverCubit>().loadAll();
            return;
          }
          // Mọi filter còn lại (Khám phá/Yêu thích/Đã lưu/Đã tải lên)
          // → push AllEbooksScreen với filter tương ứng.
          final f = FilterType.values.firstWhere(
            (e) => e.name == filter,
            orElse: () => FilterType.all,
          );
          _openAllEbooks(filter: f);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
        child: BlocBuilder<DiscoverCubit, DiscoverState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _DiscoverSectionView(
                  title: AppLocalizations.current.new_ebooks,
                  icon: Icons.fiber_new_rounded,
                  accent: const Color(0xFF6366F1),
                  state: state.newest,
                  onSeeAll: () => _openAllEbooks(filter: FilterType.all),
                  onRetry: () => context
                      .read<DiscoverCubit>()
                      .refreshSection(DiscoverSection.newest),
                  onTapBook: (book) => _openBook(book),
                  onLongPressBook: (book) {
                    BookOptionsBottomSheet.show(
                      context,
                      book: book,
                      userInteractionCubit: context.read<UserInteractionCubit>(),
                      ownerId: _userInfo?.id,
                      onRead: (b, f) => _openBook(b, selectedFile: f),
                    );
                  },
                ),
                _DiscoverSectionView(
                  title: AppLocalizations.current.popular_ebooks,
                  icon: Icons.local_fire_department_rounded,
                  accent: const Color(0xFFEF4444),
                  state: state.popular,
                  onSeeAll: () => _openAllEbooks(filter: FilterType.all),
                  onRetry: () => context
                      .read<DiscoverCubit>()
                      .refreshSection(DiscoverSection.popular),
                  onTapBook: (book) => _openBook(book),
                  onLongPressBook: (book) {
                    BookOptionsBottomSheet.show(
                      context,
                      book: book,
                      userInteractionCubit: context.read<UserInteractionCubit>(),
                      ownerId: _userInfo?.id,
                      onRead: (b, f) => _openBook(b, selectedFile: f),
                    );
                  },
                ),
                _DiscoverSectionView(
                  title: AppLocalizations.current.recommended_for_you,
                  icon: Icons.auto_awesome_rounded,
                  accent: const Color(0xFF06B6D4),
                  state: state.recommended,
                  onSeeAll: () => _openAllEbooks(filter: FilterType.all),
                  onRetry: () => context
                      .read<DiscoverCubit>()
                      .refreshSection(DiscoverSection.recommended),
                  onTapBook: (book) => _openBook(book),
                  onLongPressBook: (book) {
                    BookOptionsBottomSheet.show(
                      context,
                      book: book,
                      userInteractionCubit: context.read<UserInteractionCubit>(),
                      ownerId: _userInfo?.id,
                      onRead: (b, f) => _openBook(b, selectedFile: f),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return ValueListenableBuilder<int>(
      valueListenable: context.read<NotificationCubit>().unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_12,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
                onTap: () =>
                    Navigator.pushNamed(context, Routes.notificationScreen),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: AppSize.iconSizeXXLarge,
                    height: AppSize.iconSizeXXLarge,
                    child: SvgPicture.asset(
                      Assets.icons.icRing,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 0,
                right: 12,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.notificationScreen,
                  ),
                  child: Badge(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    label: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Một section trên màn Discover: header + horizontal list.
class _DiscoverSectionView extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final DiscoverSectionState state;
  final VoidCallback onSeeAll;
  final VoidCallback onRetry;
  final ValueChanged<BookModel> onTapBook;
  final ValueChanged<BookModel>? onLongPressBook;

  const _DiscoverSectionView({
    required this.title,
    required this.icon,
    required this.accent,
    required this.state,
    required this.onSeeAll,
    required this.onRetry,
    required this.onTapBook,
    this.onLongPressBook,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.current.see_all,
                      style: TextStyle(
                        fontSize: 13,
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Loading skeleton.
    if (state.isLoading && state.books.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
      );
    }
    // Error trong section: hiển thị compact retry, không phá vỡ các section khác.
    if (state.error != null && state.books.isEmpty) {
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error),
              const SizedBox(height: 6),
              Text(
                state.error ?? '',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.current.try_again),
              ),
            ],
          ),
        ),
      );
    }
    if (state.books.isEmpty) {
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            AppLocalizations.current.no_books_for_section,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _DiscoverBookCard(
          book: state.books[index],
          onTap: () => onTapBook(state.books[index]),
          onLongPress: onLongPressBook != null ? () => onLongPressBook!(state.books[index]) : null,
        ),
      ),
    );
  }
}

/// Card compact dùng riêng cho horizontal list của Discover.
/// Không tái dùng `BookCard` thường vì BookCard yêu cầu nhiều phụ thuộc
/// (interaction stats, delete, rating...) chỉ phù hợp ở màn AllEbooks dạng grid.
class _DiscoverBookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DiscoverBookCard({required this.book, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 130,
                height: 170,
                child: BaseNetworkImage(
                  url: UrlBuilder.buildUrl(book.coverImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if ((book.author ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                book.author ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
