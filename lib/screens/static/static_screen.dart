import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/transaction_provider.dart';

class StaticScreen extends ConsumerStatefulWidget {
  const StaticScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaticScreen> createState() => _StaticScreenState();
}

class _StaticScreenState extends ConsumerState<StaticScreen> {
  int _selectedPeriod = 0; // 0: Day, 1: Week, 2: Month, 3: Year
  String _selectedType = 'Expense';

  final List<String> periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              Row(
                children: List.generate(4, (index) {
                  final isSelected = _selectedPeriod == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2F7F78)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          periods[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Expense/Income dropdown
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: ['Expense', 'Income'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Chart
              transactionsAsync.when(
                data: (transactions) {
                  // Filter transactions based on selected type
                  final filteredTransactions = transactions.where((t) {
                    return _selectedType == 'Expense'
                        ? t.type == 'expense'
                        : t.type == 'income';
                  }).toList();

                  // Calculate total
                  final total = filteredTransactions.fold(
                    0.0,
                    (sum, t) => sum + t.amount,
                  );

                  // Generate chart data based on selected period
                  final chartData = _generateChartData(filteredTransactions);
                  final maxY = chartData.isEmpty
                      ? 100.0
                      : chartData
                                .map((e) => e.y)
                                .reduce((a, b) => a > b ? a : b) ==
                            0
                      ? 100.0
                      : chartData
                                .map((e) => e.y)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2;
                  final highestIndex = chartData.isEmpty
                      ? -1
                      : chartData.indexOf(
                          chartData.reduce((a, b) => a.y > b.y ? a : b),
                        );

                  return Column(
                    children: [
                      // Total amount
                      Text(
                        '₹${total.toStringAsFixed(2).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F7F78),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Chart
                      SizedBox(
                        height: 200,
                        child: chartData.isEmpty
                            ? Center(
                                child: Text(
                                  'No data available',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: maxY / 5,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 35,
                                        interval: 1,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              final labels = _getChartLabels();
                                              if (value.toInt() >= 0 &&
                                                  value.toInt() <
                                                      labels.length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10,
                                                      ),
                                                  child: Text(
                                                    labels[value.toInt()],
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (chartData.length - 1).toDouble(),
                                  minY: 0,
                                  maxY: maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartData,
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF2F7F78,
                                          ).withOpacity(0.8),
                                          const Color(0xFF2F7F78),
                                        ],
                                      ),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                              if (highestIndex >= 0 &&
                                                  index == highestIndex) {
                                                return FlDotCirclePainter(
                                                  radius: 6,
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                  strokeColor: const Color(
                                                    0xFF2F7F78,
                                                  ),
                                                );
                                              }
                                              return FlDotCirclePainter(
                                                radius: 0,
                                                color: Colors.transparent,
                                              );
                                            },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFF2F7F78,
                                            ).withOpacity(0.2),
                                            const Color(
                                              0xFF2F7F78,
                                            ).withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SizedBox(
                  height: 200,
                  child: Center(child: Text('Error: $error')),
                ),
              ),
              const SizedBox(height: 40),
              // Top Spending header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Spending',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.swap_vert, color: Colors.grey.shade600, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              // Top Spending List
              transactionsAsync.when(
                data: (transactions) {
                  print('=== TOP SPENDING DEBUG ===');
                  print('Total transactions: ${transactions.length}');

                  // Print all transactions
                  for (var t in transactions) {
                    print(
                      'Transaction: ${t.category}, Type: "${t.type}", Amount: ${t.amount}',
                    );
                  }

                  // Filter and sort transactions
                  final expenseTransactions =
                      transactions
                          .where((t) => t.type.toLowerCase() == 'expense')
                          .toList()
                        ..sort((a, b) => b.amount.compareTo(a.amount));

                  print('Expense transactions: ${expenseTransactions.length}');

                  if (expenseTransactions.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F7F78).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Color(0xFF2F7F78),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No expenses recorded',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add expenses to see your top spending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final topExpenses = expenseTransactions.take(5).toList();
                  print('Top expenses to display: ${topExpenses.length}');

                  return Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: topExpenses.map((transaction) {
                        print('Building item for: ${transaction.category}');
                        return _buildSpendingItem(
                          transaction.category,
                          _formatDate(transaction.date),
                          transaction.amount,
                          _getCategoryIcon(transaction.category),
                          _getCategoryColor(transaction.category),
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingItem(
    String title,
    String date,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '- ₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5252),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  List<FlSpot> _generateChartData(List<dynamic> transactions) {
    if (transactions.isEmpty) return [];

    final now = DateTime.now();
    final Map<int, double> dataPoints = {};

    switch (_selectedPeriod) {
      case 0: // Day - Last 7 days
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          final dayTransactions = transactions.where((t) {
            final tDate = t.date;
            return tDate.year == day.year &&
                tDate.month == day.month &&
                tDate.day == day.day;
          });
          dataPoints[6 - i] = dayTransactions.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );
        }
        break;

      case 1: // Week - Last 7 weeks
        for (int i = 6; i >= 0; i--) {
          final weekStart = now.subtract(
            Duration(days: now.weekday - 1 + (i * 7)),
          );
          final weekEnd = weekStart.add(const Duration(days: 6));
          final weekTransactions = transactions.where((t) {
            return t.date.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(weekEnd.add(const Duration(days: 1)));
          });
          dataPoints[6 - i] = weekTransactions.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );
        }
        break;

      case 2: // Month - Last 7 months
        for (int i = 6; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final monthTransactions = transactions.where((t) {
            return t.date.year == month.year && t.date.month == month.month;
          });
          dataPoints[6 - i] = monthTransactions.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );
        }
        break;

      case 3: // Year - Last 7 years
        for (int i = 6; i >= 0; i--) {
          final year = now.year - i;
          final yearTransactions = transactions.where((t) {
            return t.date.year == year;
          });
          dataPoints[6 - i] = yearTransactions.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );
        }
        break;
    }

    return dataPoints.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  List<String> _getChartLabels() {
    final now = DateTime.now();
    final List<String> labels = [];

    switch (_selectedPeriod) {
      case 0: // Day - Last 7 days
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          labels.add(DateFormat('EEE').format(day));
        }
        break;

      case 1: // Week - Last 7 weeks
        for (int i = 6; i >= 0; i--) {
          labels.add('W${now.weekday - i}');
        }
        break;

      case 2: // Month - Last 7 months
        for (int i = 6; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          labels.add(DateFormat('MMM').format(month));
        }
        break;

      case 3: // Year - Last 7 years
        for (int i = 6; i >= 0; i--) {
          final year = now.year - i;
          labels.add(year.toString().substring(2));
        }
        break;
    }

    return labels;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFF00BFA5);
      case 'travel':
        return const Color(0xFF448AFF);
      case 'shopping':
        return const Color(0xFFFF6F00);
      case 'bills':
        return const Color(0xFFD32F2F);
      case 'transfer':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF2F7F78);
    }
  }
}
