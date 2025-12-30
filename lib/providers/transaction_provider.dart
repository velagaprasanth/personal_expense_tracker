import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

part 'transaction_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionService transactionService(TransactionServiceRef ref) {
  return TransactionService();
}

@Riverpod(keepAlive: true)
class Transactions extends _$Transactions {
  TransactionService get _service => ref.watch(transactionServiceProvider);

  @override
  Future<List<Transaction>> build() async {
    return _service.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _service.addTransaction(transaction);
    ref.invalidateSelf();
    _invalidateSummaries();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _service.updateTransaction(transaction);
    ref.invalidateSelf();
    _invalidateSummaries();
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
    ref.invalidateSelf();
    _invalidateSummaries();
  }

  void _invalidateSummaries() {
    ref.invalidate(balanceProvider);
    ref.invalidate(totalIncomeProvider);
    ref.invalidate(totalExpensesProvider);
  }
}

@Riverpod(keepAlive: true)
Future<double> balance(BalanceRef ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getBalance();
}

@Riverpod(keepAlive: true)
Future<double> totalIncome(TotalIncomeRef ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTotalIncome();
}

@Riverpod(keepAlive: true)
Future<double> totalExpenses(TotalExpensesRef ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTotalExpenses();
}
