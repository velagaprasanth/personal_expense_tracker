import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all transactions for the current user
  Future<List<Transaction>> getTransactions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Add a new transaction
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final transactionWithUser = transaction.copyWith(userId: userId);
      
      final response = await _supabase
          .from('transactions')
          .insert(transactionWithUser.toJson())
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Update a transaction
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.id == null) {
        throw Exception('Transaction ID is required for update');
      }

      final response = await _supabase
          .from('transactions')
          .update(transaction.toJson())
          .eq('id', transaction.id!)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get total income
  Future<double> getTotalIncome() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0.0;

      final transactions = await getTransactions();
      return transactions
          .where((t) => t.type == 'income')
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  // Get total expenses
  Future<double> getTotalExpenses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0.0;

      final transactions = await getTransactions();
      return transactions
          .where((t) => t.type == 'expense')
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }

  // Get balance
  Future<double> getBalance() async {
    try {
      final income = await getTotalIncome();
      final expenses = await getTotalExpenses();
      return income - expenses;
    } catch (e) {
      return 0.0;
    }
  }
}
