import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../repositories/book_repository.dart';
import '../widgets/loading_widget.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String>? _searchResults;
  bool _notFound = false;

  Future<void> _performSearch(String query, Set<String> favorites) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = null;
        _notFound = false;
      });
      return;
    }

    try {
      final favList = favorites.toList();
      final matched = <String>[];

      final futures =
          favList.map((workId) async {
            try {
              final detail = await context
                  .read<BookRepository>()
                  .fetchBookDetail(workId);
              final title = (detail.title as String?) ?? '';
              final authorsList = detail.authors as List<dynamic>?;
              final authors = authorsList?.join(', ') ?? '';
              final hay = '$title $authors $workId'.toLowerCase();
              if (hay.contains(q.toLowerCase())) matched.add(workId);
            } catch (_) {}
          }).toList();

      await Future.wait(futures);

      setState(() {
        _searchResults = matched;
        _notFound = matched.isEmpty;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _notFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (ctx, state) {
        if (state is FavoritesInitial) return const LoadingWidget();
        if (state is FavoritesLoaded) {
          final favs = state.favorites;
          if (favs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          if (_notFound) {
            return const Center(child: Text('404: Not found'));
          }
          final listToShow = _searchResults ?? favs.toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (q) => _performSearch(q, favs),
                  decoration: InputDecoration(
                    hintText: 'Search favorites',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed:
                          () => _performSearch(_searchController.text, favs),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listToShow.length,
                  itemBuilder: (context, index) {
                    final workId = listToShow[index];
                    return FutureBuilder(
                      future: context.read<BookRepository>().fetchBookDetail(
                        workId,
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        if (snap.hasError) {
                          return ListTile(title: Text('Error loading $workId'));
                        }
                        final detail = snap.data as dynamic;
                        final title = (detail?.title as String?) ?? workId;
                        final authors =
                            (detail?.authors as List<dynamic>?)?.join(', ') ??
                            '';
                        return ListTile(
                          leading:
                              (detail?.coverUrl as String?)?.isNotEmpty == true
                                  ? Image.network(
                                    detail.coverUrl as String,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(Icons.book),
                                  )
                                  : const Icon(Icons.book),
                          title: Text(title),
                          subtitle: Text(authors),
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => BookDetailScreen(workId: workId),
                                ),
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
