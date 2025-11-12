import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/book_list/book_list_bloc.dart';
import '../../blocs/book_list/book_list_event.dart';
import '../../blocs/book_list/book_list_state.dart';
import '../widgets/book_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'favorites_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchSubmitted(String q) {
    context.read<BookListBloc>().add(SearchBooks(q));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildListPage(), const FavoritesScreen()];
    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: const Text('Book Explorer'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Search books',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed:
                              () => _onSearchSubmitted(_searchController.text),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              )
              : AppBar(title: const Text('Favorites')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  Widget _buildListPage() {
    return BlocBuilder<BookListBloc, BookListState>(
      builder: (context, state) {
        if (state is BookListLoading || state is BookListInitial) {
          return const LoadingWidget();
        } else if (state is BookListError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => context.read<BookListBloc>().add(RefreshBooks()),
          );
        } else if (state is BookListEmpty) {
          return const Center(child: Text('No results found'));
        } else if (state is BookListLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<BookListBloc>().add(RefreshBooks());
            },
            child: ListView.builder(
              itemCount: state.books.length,
              itemBuilder: (context, idx) {
                final b = state.books[idx];
                return BookListItem(
                  book: b,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(workId: b.workId),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
