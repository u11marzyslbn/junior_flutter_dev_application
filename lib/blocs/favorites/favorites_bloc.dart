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
      _favorites = favoritesRepository.loadFavorites();
      emit(FavoritesLoaded(_favorites));
    });
    on<ToggleFavorite>((e, emit) async {
      if (_favorites.contains(e.workId)) {
        _favorites.remove(e.workId);
      } else {
        _favorites.add(e.workId);
      }
      await favoritesRepository.saveFavorites(_favorites);
      emit(FavoritesLoaded(Set.from(_favorites)));
    });
  }
}
