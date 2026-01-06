import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryCubit>(
      create: (_) => getIt.get<LibraryCubit>()..getBooks(),
      child: const LibraryBody(),
    );
  }
}

class LibraryBody extends StatefulWidget {
  const LibraryBody({Key? key}) : super(key: key);

  @override
  State<LibraryBody> createState() => _LibraryBodyState();
}

class _LibraryBodyState extends State<LibraryBody> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int page = 1;
  int limit = 10;
  String categoryId = "";
  FilterType filterType = FilterType.all;
  @override
  void initState() {
    super.initState();
    context.read<LibraryCubit>().getBooks(filterType: filterType, page: page, limit: limit, categoryId: categoryId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'My Library',
      stateWidget: CustomLoading<LibraryCubit>(),
      messageNotify: CustomSnackBar<LibraryCubit>(),
      rightWidgets: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<LibraryCubit>().getBooks(filterType: filterType, page: page, limit: limit, categoryId: categoryId);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/adminUploadScreen');
          },
        ),
      ],
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  context.read<LibraryCubit>().searchBooks(searchQuery: value, filterType: filterType);
                },
              ),
            ),
          Expanded(
            child: BlocListener<BookRefreshCubit, int>(
              listener: (context, state) {
                // Lắng nghe sự thay đổi từ BookRefreshCubit
                if (state > 0) {
                  context.read<LibraryCubit>().getBooks(filterType: filterType, page: page, limit: limit, categoryId: categoryId);
                }
              },
              child: BlocBuilder<LibraryCubit, BaseState>(
              builder: (context, state) {
                if (state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.data}'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LibraryCubit>().getBooks(filterType: filterType, page: page, limit: limit, categoryId: categoryId);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is LoadedState) {
                  final books = state.data as List<BookModel>;
                  
                  if (books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No books yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first book',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<LibraryCubit>().refreshBooks();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return _BookCard(book: books[index]);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to book detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: ${book.displayTitle}')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: book.coverImageUrl != null
                    ? Image.asset(
                        book.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.displayAuthor,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (book.isFavorite == true)
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                        Text(
                          book.fileSizeFormatted,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.book,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }
}

