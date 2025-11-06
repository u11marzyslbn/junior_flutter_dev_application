import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_list_event.dart';
import 'book_list_state.dart';
import '../../repositories/book_repository.dart';

class BookListBloc extends Bloc<BookListEvent, BookListState> {
  final BookRepository bookRepository;
  BookListBloc({required this.bookRepository}) : super(BookListInitial()) {
    on<FetchSubjectBooks>((e, emit) => _onFetch(emit));
    on<SearchBooks>((e, emit) => _onSearch(e.query, emit));
    on<RefreshBooks>((e, emit) => _onFetch(emit));
  }

  Future<void> _onFetch(Emitter<BookListState> emit) async {
    emit(BookListLoading());
    try {
      final books = await bookRepository.fetchSubjectBooks();
      if (books.isEmpty) {
        emit(BookListEmpty());
      } else {
        emit(BookListLoaded(books));
      }
    } catch (ex) {
      emit(BookListError(ex.toString()));
    }
  }

  Future<void> _onSearch(String query, Emitter<BookListState> emit) async {
    if (query.trim().isEmpty) {
      add(FetchSubjectBooks());
      return;
    }
    emit(BookListLoading());
    try {
      final books = await bookRepository.searchBooks(query);
      if (books.isEmpty) {
        emit(BookListEmpty());
      } else {
        emit(BookListLoaded(books, isFromSearch: true));
      }
    } catch (ex) {
      emit(BookListError(ex.toString()));
    }
  }
}
