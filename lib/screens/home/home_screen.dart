import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/transaction_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final balanceAsync = ref.watch(balanceProvider);
    final incomeAsync = ref.watch(totalIncomeProvider);
    final expensesAsync = ref.watch(totalExpensesProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      body: Stack(
        children: [
          /// 🔹 CURVED BACKGROUND (SHORTER + DARKER)
          Container(
            height: MediaQuery.of(context).size.height * 0.30, // ⬅ reduced
            decoration: const BoxDecoration(
              color: Color(0xFF2F7F78), // ⬅ darker
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔹 HEADER
                Padding(       
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.userMetadata?['full_name'] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                /// 🔹 BIGGER TOTAL BALANCE CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 26, // ⬅ increased height
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF256D67), // darker than bg
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),

                        /// BALANCE TEXT (BIGGER)
                        balanceAsync.when(
                          data: (balance) => Text(
                            '₹${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36, // ⬅ increased
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const Text(
                            '₹0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (_, __) => const Text(
                            '₹0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// INCOME & EXPENSE (BIGGER FONT)
                        Row(
                          children: [
                            Expanded(
                              child: incomeAsync.when(
                                data: (v) =>
                                    _stat(Icons.arrow_downward, 'Income', v),
                                loading: () =>
                                    _stat(Icons.arrow_downward, 'Income', 0),
                                error: (_, __) =>
                                    _stat(Icons.arrow_downward, 'Income', 0),
                              ),
                            ),
                            Expanded(
                              child: expensesAsync.when(
                                data: (v) =>
                                    _stat(Icons.arrow_upward, 'Expenses', v),
                                loading: () =>
                                    _stat(Icons.arrow_upward, 'Expenses', 0),
                                error: (_, __) =>
                                    _stat(Icons.arrow_upward, 'Expenses', 0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                /// 🔹 TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Income & Expense Listing',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('See all', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔹 SCROLLABLE LIST
                Expanded(
                  child: transactionsAsync.when(
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return const Center(child: Text('No transactions yet'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final isIncome = t.type.toLowerCase() == 'income';

                          return Dismissible(
                            key: ValueKey(
                              t.id ?? '${t.date.millisecondsSinceEpoch}-$index',
                            ),
                            background: _buildSwipeBackground(
                              alignment: Alignment.centerLeft,
                              color: const Color(0xFF2F7F78).withOpacity(0.85),
                              label: 'Edit',
                            ),
                            secondaryBackground: _buildSwipeBackground(
                              alignment: Alignment.centerRight,
                              color: Colors.red.shade600,
                              label: 'Delete',
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                final route = isIncome
                                    ? '/add-income'
                                    : '/add-expense';
                                context.push(route, extra: t);
                                return false;
                              }

                              final shouldDelete =
                                  await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Delete transaction?',
                                        ),
                                        content: const Text(
                                          'This will permanently remove the selected transaction.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false;

                              if (!shouldDelete) return false;

                              if (t.id == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This entry cannot be deleted right now.',
                                    ),
                                  ),
                                );
                                return false;
                              }

                              try {
                                await ref
                                    .read(transactionsProvider.notifier)
                                    .deleteTransaction(t.id!);
                                ref.invalidate(balanceProvider);
                                ref.invalidate(totalIncomeProvider);
                                ref.invalidate(totalExpensesProvider);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaction deleted'),
                                  ),
                                );
                                return true;
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return false;
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(t.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isIncome ? '+' : '-'} ₹${t.amount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIncome
                                          ? const Color(0xFF2F7F78)
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 INCOME / EXPENSE STAT
  Widget _stat(IconData icon, String label, double value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13, // ⬅ increased
              ),
            ),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // ⬅ increased
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
