// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionServiceHash() =>
    r'6f9f7b050629d6ead752a4e254674ea48cbb41e9';

/// See also [transactionService].
@ProviderFor(transactionService)
final transactionServiceProvider = Provider<TransactionService>.internal(
  transactionService,
  name: r'transactionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionServiceRef = ProviderRef<TransactionService>;
String _$balanceHash() => r'73beed72f730f003066dbb0b1d46ee1cd0ec0cc9';

/// See also [balance].
@ProviderFor(balance)
final balanceProvider = FutureProvider<double>.internal(
  balance,
  name: r'balanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$balanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BalanceRef = FutureProviderRef<double>;
String _$totalIncomeHash() => r'c0611d9b7800ccf8fd5eba21c0cc5d87879195f1';

/// See also [totalIncome].
@ProviderFor(totalIncome)
final totalIncomeProvider = FutureProvider<double>.internal(
  totalIncome,
  name: r'totalIncomeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalIncomeRef = FutureProviderRef<double>;
String _$totalExpensesHash() => r'41876ba13186cb20425e0e4755e2a6d8fe0d9dfe';

/// See also [totalExpenses].
@ProviderFor(totalExpenses)
final totalExpensesProvider = FutureProvider<double>.internal(
  totalExpenses,
  name: r'totalExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalExpensesRef = FutureProviderRef<double>;
String _$transactionsHash() => r'218b403b23fd2e8603a87113a89ef4b70c40c50a';

/// See also [Transactions].
@ProviderFor(Transactions)
final transactionsProvider =
    AsyncNotifierProvider<Transactions, List<Transaction>>.internal(
      Transactions.new,
      name: r'transactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Transactions = AsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
