import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/data/datasources/transaction_remote_datasource.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final int page;
  final bool refresh;
  LoadTransactions({this.page = 1, this.refresh = false});
}

class CreateTransaction extends TransactionEvent {
  final Map<String, dynamic> data;
  final Uint8List? imageBytes;
  final String? imageName;
  CreateTransaction({
    required this.data,
    this.imageBytes,
    this.imageName,
  });
}

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final int currentPage;
  final int lastPage;
  final int total;
  TransactionsLoaded({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class TransactionCreated extends TransactionState {
  final TransactionModel transaction;
  TransactionCreated(this.transaction);
}

class TransactionFailure extends TransactionState {
  final String message;
  TransactionFailure(this.message);
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRemoteDatasource _datasource = TransactionRemoteDatasource();
  List<TransactionModel> _allTransactions = [];
  int _currentPage = 1;
  int _lastPage = 1;

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) async {
      if (event.refresh) {
        _currentPage = 1;
        _allTransactions = [];
      }
      emit(TransactionLoading());
      try {
        final result = await _datasource.getTransactions(page: event.page);
        final newTxs = result['transactions'] as List<TransactionModel>;
        _allTransactions.addAll(newTxs);
        _currentPage = result['current_page'] as int;
        _lastPage = result['last_page'] as int;
        emit(TransactionsLoaded(
          transactions: List.from(_allTransactions),
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: result['total'] as int,
        ));
      } catch (e) {
        emit(TransactionFailure(e.toString()));
      }
    });

    on<CreateTransaction>((event, emit) async {
      emit(TransactionLoading());
      try {
        final tx = await _datasource.createTransaction(
          event.data,
          imageBytes: event.imageBytes,
          imageName: event.imageName,
        );
        emit(TransactionCreated(tx));
        add(LoadTransactions(refresh: true));
      } catch (e) {
        emit(TransactionFailure(e.toString()));
      }
    });
  }
}
