import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junior_flutter_dev_application/blocs/book_list/book_list_event.dart';
import 'package:junior_flutter_dev_application/blocs/favorites/favorites_event.dart';
import 'repositories/book_repository.dart';
import 'repositories/favorites_repository.dart';
import 'services/api_service.dart';
import 'blocs/book_list/book_list_bloc.dart';
import 'blocs/favorites/favorites_bloc.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final bookRepo = BookRepository(api: api);
  final favoritesRepo = await FavoritesRepository.create();
  runApp(MainApp(bookRepository: bookRepo, favoritesRepository: favoritesRepo));
}

class MainApp extends StatelessWidget {
  final BookRepository bookRepository;
  final FavoritesRepository favoritesRepository;
  const MainApp({
    super.key,
    required this.bookRepository,
    required this.favoritesRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: bookRepository),
        RepositoryProvider.value(value: favoritesRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) =>
                    BookListBloc(bookRepository: bookRepository)
                      ..add(FetchSubjectBooks()),
          ),
          BlocProvider(
            create:
                (_) =>
                    FavoritesBloc(favoritesRepository: favoritesRepository)
                      ..add(LoadFavorites()),
          ),
        ],
        child: const MaterialApp(
          title: 'junior_flutter_dev_application',
          home: HomeScreen(),
        ),
      ),
    );
  }
}
