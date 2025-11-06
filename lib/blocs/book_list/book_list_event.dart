import 'package:equatable/equatable.dart';

abstract class BookListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSubjectBooks extends BookListEvent {}

class SearchBooks extends BookListEvent {
  final String query;
  SearchBooks(this.query);
  @override
  List<Object?> get props => [query];
}

class RefreshBooks extends BookListEvent {}
