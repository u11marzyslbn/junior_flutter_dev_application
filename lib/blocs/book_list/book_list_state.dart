import 'package:equatable/equatable.dart';
import '../../models/book.dart';

abstract class BookListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookListInitial extends BookListState {}

class BookListLoading extends BookListState {}

class BookListLoaded extends BookListState {
  final List<Book> books;
  final bool isFromSearch;
  BookListLoaded(this.books, {this.isFromSearch = false});
  @override
  List<Object?> get props => [books, isFromSearch];
}

class BookListEmpty extends BookListState {}

class BookListError extends BookListState {
  final String message;
  BookListError(this.message);
  @override
  List<Object?> get props => [message];
}
