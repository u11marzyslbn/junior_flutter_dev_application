import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../repositories/book_repository.dart';
import '../widgets/loading_widget.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (ctx, state) {
        if (state is FavoritesInitial) return const LoadingWidget();
        if (state is FavoritesLoaded) {
          if (state.favorites.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final workId = state.favorites.elementAt(index);
              return FutureBuilder(
                future: context.read<BookRepository>().fetchBookDetail(workId),
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
                      (detail?.authors as List<dynamic>?)?.join(', ') ?? '';
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
                            builder: (_) => BookDetailScreen(workId: workId),
                          ),
                        ),
                  );
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
