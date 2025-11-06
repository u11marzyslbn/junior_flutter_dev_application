import 'package:equatable/equatable.dart';
import '../../models/book_detail.dart';

abstract class BookDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookDetailInitial extends BookDetailState {}

class BookDetailLoading extends BookDetailState {}

class BookDetailLoaded extends BookDetailState {
  final BookDetail detail;
  BookDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class BookDetailError extends BookDetailState {
  final String message;
  BookDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
