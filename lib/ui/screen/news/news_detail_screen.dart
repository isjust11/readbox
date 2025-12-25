import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/routes.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsCubit>(
      create: (_) => getIt.get<NewsCubit>(),
      child: NewsDetailBody(news: news),
    );
  }
}

class NewsDetailBody extends StatefulWidget {
  final NewsModel news;

  const NewsDetailBody({Key? key, required this.news}) : super(key: key);

  @override
  State<NewsDetailBody> createState() => _NewsDetailBodyState();
}

class _NewsDetailBodyState extends State<NewsDetailBody> {
  late NewsModel _news;

  @override
  void initState() {
    super.initState();
    _news = widget.news;
  }

  void _editNews() {
    Navigator.pushNamed(
      context,
      Routes.newsCreateEditScreen,
      arguments: _news,
    ).then((value) {
      if (value == true) {
        // Refresh if news was updated
        context.read<NewsCubit>().refreshNews();
      }
    });
  }

  void _deleteNews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News'),
        content: const Text('Are you sure you want to delete this news?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_news.id != null) {
                context.read<NewsCubit>().deleteNews(_news.id!.toString());
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar với Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _news.hasImage
                      ? Image.network(
                          _news.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.article, size: 100, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.article, size: 100, color: Colors.grey),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editNews,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteNews,
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _news.displayTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meta information
                  Row(
                    children: [
                      if (_news.author != null)
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _news.displayAuthor,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _news.publishedDateFormatted,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (_news.viewCount != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${_news.viewCount} views',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category and Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_news.category != null)
                        Chip(
                          label: Text(_news.displayCategory),
                          backgroundColor: Colors.blue[100],
                        ),
                      if (_news.tags != null && _news.tags!.isNotEmpty)
                        ..._news.tags!.map((tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 12),
                            )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary
                  if (_news.summary != null && _news.summary!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _news.summary!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Content
                  if (_news.content != null && _news.content!.isNotEmpty)
                    Text(
                      _news.content!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Source
                  if (_news.source != null || _news.sourceUrl != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Source:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (_news.source != null)
                            Text(_news.source!),
                          if (_news.sourceUrl != null)
                            Text(
                              _news.sourceUrl!,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

