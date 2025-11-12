import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/book_detail/book_detail_bloc.dart';
import '../../blocs/book_detail/book_detail_event.dart';
import '../../blocs/book_detail/book_detail_state.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../repositories/book_repository.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class BookDetailScreen extends StatelessWidget {
  final String workId;
  const BookDetailScreen({super.key, required this.workId});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: RepositoryProvider.of<BookRepository>(context),
      child: BlocProvider(
        create:
            (ctx) =>
                BookDetailBloc(bookRepository: ctx.read<BookRepository>())
                  ..add(LoadBookDetail(workId)),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Book Detail'),
            actions: [
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (ctx, favState) {
                  final isFav =
                      favState is FavoritesLoaded &&
                      favState.favorites.contains(workId);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.yellow : null,
                    ),
                    onPressed:
                        () => ctx.read<FavoritesBloc>().add(
                          ToggleFavorite(workId),
                        ),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<BookDetailBloc, BookDetailState>(
            builder: (context, state) {
              if (state is BookDetailLoading || state is BookDetailInitial) {
                return const LoadingWidget();
              } else if (state is BookDetailError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<BookDetailBloc>().add(LoadBookDetail(workId));
                  },
                );
              } else if (state is BookDetailLoaded) {
                final d = state.detail;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.coverUrl.isNotEmpty)
                        Center(
                          child: Image.network(
                            d.coverUrl,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        d.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Authors: ${d.authors.join(', ')}'),
                      const SizedBox(height: 8),
                      if (d.firstPublishYear != null)
                        Text('First published: ${d.firstPublishYear}'),
                      const SizedBox(height: 8),
                      if (d.subjects != null)
                        Text('Subjects: ${d.subjects!.join(', ')}'),
                      const SizedBox(height: 12),
                      if (d.description != null) Text(d.description!),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
