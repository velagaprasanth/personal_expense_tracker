import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

// Service provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService();
});

// Transactions list provider
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
  (ref) => TransactionsNotifier(ref.read(transactionServiceProvider)),
);

class TransactionsNotifier
    extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionService _service;

  TransactionsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _service.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _service.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _service.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      rethrow;
    }
  }
}

// Balance provider
final balanceProvider = FutureProvider<double>((ref) async {
  final service = ref.read(transactionServiceProvider);
  return await service.getBalance();
});

// Total income provider
final totalIncomeProvider = FutureProvider<double>((ref) async {
  final service = ref.read(transactionServiceProvider);
  return await service.getTotalIncome();
});

// Total expenses provider
final totalExpensesProvider = FutureProvider<double>((ref) async {
  final service = ref.read(transactionServiceProvider);
  return await service.getTotalExpenses();
});
