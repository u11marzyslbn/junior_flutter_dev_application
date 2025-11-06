import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favorites;
  FavoritesLoaded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}
