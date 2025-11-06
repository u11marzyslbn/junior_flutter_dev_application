import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final String workId;
  ToggleFavorite(this.workId);
  @override
  List<Object?> get props => [workId];
}
