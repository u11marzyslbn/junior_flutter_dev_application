import 'package:equatable/equatable.dart';

abstract class BookDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBookDetail extends BookDetailEvent {
  final String workId;
  LoadBookDetail(this.workId);
  @override
  List<Object?> get props => [workId];
}
