import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import '../../repositories/favorites_repository.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository favoritesRepository;
  Set<String> _favorites = {};

  FavoritesBloc({required this.favoritesRepository})
    : super(FavoritesInitial()) {
    on<LoadFavorites>((e, emit) {
      final loaded = favoritesRepository.loadFavorites();
      _favorites = Set<String>.from(loaded);
      emit(FavoritesLoaded(Set.unmodifiable(_favorites)));
    });
    on<ToggleFavorite>((e, emit) async {
      final newFavorites = Set<String>.from(_favorites);
      if (newFavorites.contains(e.workId)) {
        newFavorites.remove(e.workId);
      } else {
        newFavorites.add(e.workId);
      }
      await favoritesRepository.saveFavorites(newFavorites);
      _favorites = newFavorites;
      emit(FavoritesLoaded(Set.unmodifiable(_favorites)));
    });
  }
}
