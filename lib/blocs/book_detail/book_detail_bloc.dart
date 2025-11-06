import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_detail_event.dart';
import 'book_detail_state.dart';
import '../../repositories/book_repository.dart';

class BookDetailBloc extends Bloc<BookDetailEvent, BookDetailState> {
  final BookRepository bookRepository;
  BookDetailBloc({required this.bookRepository}) : super(BookDetailInitial()) {
    on<LoadBookDetail>((e, emit) => _onLoad(e.workId, emit));
  }

  Future<void> _onLoad(String workId, Emitter<BookDetailState> emit) async {
    emit(BookDetailLoading());
    try {
      final d = await bookRepository.fetchBookDetail(workId);
      emit(BookDetailLoaded(d));
    } catch (ex) {
      emit(BookDetailError(ex.toString()));
    }
  }
}
