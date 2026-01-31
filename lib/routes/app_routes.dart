import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/static/static_screen.dart';
import '../screens/add_expense/add_expense_screen.dart';
import '../screens/add_income/add_income_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/transaction.dart' as app_models;
import '../providers/transaction_provider.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

late final GoRouter appRouter = _createRouter();

GoRouter _createRouter() {
  final authStream = Supabase.instance.client.auth.onAuthStateChange;
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final location = state.matchedLocation;
      final isSplash = location == '/';
      final isPublicRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/onboarding';

      if (isSplash) {
        return null;
      }

      if (session == null) {
        return isPublicRoute ? null : '/login';
      }

      if (session != null && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/statistics',
            builder: (context, state) => const StaticScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletShell(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => AddExpenseScreen(
          transaction: state.extra as app_models.Transaction?,
        ),
      ),
      GoRoute(
        path: '/add-income',
        builder: (context, state) => AddIncomeScreen(
          transaction: state.extra as app_models.Transaction?,
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}

class WalletShell extends ConsumerWidget {
  const WalletShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7F78),
        elevation: 0,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F7F78).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 64,
                      color: Color(0xFF2F7F78),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No transaction history',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transactions will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.type.toLowerCase() == 'income';
              final dateTime = DateFormat(
                'MMM dd, yyyy',
              ).format(transaction.date);
              final time = DateFormat('hh:mm a').format(transaction.date);

              return Dismissible(
                key: ValueKey(
                  transaction.id ??
                      'wallet-${transaction.date.millisecondsSinceEpoch}-$index',
                ),
                background: _walletSwipeBackground(
                  alignment: Alignment.centerLeft,
                  color: const Color(0xFF2F7F78).withOpacity(0.85),
                  label: 'Edit',
                ),
                secondaryBackground: _walletSwipeBackground(
                  alignment: Alignment.centerRight,
                  color: Colors.red.shade600,
                  label: 'Delete',
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    final route = isIncome ? '/add-income' : '/add-expense';
                    context.push(route, extra: transaction);
                    return false;
                  }

                  final shouldDelete =
                      await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete transaction?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (!shouldDelete) return false;

                  if (transaction.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to delete this record.'),
                      ),
                    );
                    return false;
                  }

                  try {
                    await ref
                        .read(transactionsProvider.notifier)
                        .deleteTransaction(transaction.id!);
                    ref.invalidate(balanceProvider);
                    ref.invalidate(totalIncomeProvider);
                    ref.invalidate(totalExpensesProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction removed.')),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dateTime • $time',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error loading transactions',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _walletSwipeBackground({
  required Alignment alignment,
  required Color color,
  required String label,
}) {
  return Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
