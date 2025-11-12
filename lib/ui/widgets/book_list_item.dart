import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/book.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';

class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const BookListItem({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          book.coverUrl.isNotEmpty
              ? Image.network(
                book.coverUrl,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.book),
              )
              : const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Text(book.authors.join(', ')),
      trailing: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (ctx, state) {
          final isFav =
              state is FavoritesLoaded && state.favorites.contains(book.workId);
          return IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.yellow : null,
            ),
            onPressed:
                () =>
                    ctx.read<FavoritesBloc>().add(ToggleFavorite(book.workId)),
          );
        },
      ),
      onTap: onTap,
    );
  }
}
