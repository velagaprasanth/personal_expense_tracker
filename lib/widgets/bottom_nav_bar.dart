import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  final Widget child;

  const BottomNavBar({Key? key, required this.child}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F7F78).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Color(0xFF2F7F78)),
              ),
              title: const Text(
                'Add Income',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-income');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, color: Colors.red.shade600),
              ),
              title: const Text(
                'Add Expense',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-expense');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (location.contains('/home')) {
      selectedIndex = 0;
    } else if (location.contains('/statistics')) {
      selectedIndex = 1;
    } else if (location.contains('/wallet')) {
      selectedIndex = 2;
    } else if (location.contains('/profile')) {
      selectedIndex = 3;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: const Color(0xFF2F7F78),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              Icons.home_outlined,
              Icons.home,
              'Home',
              0,
              selectedIndex,
              context,
            ),
            _buildNavItem(
              Icons.bar_chart_outlined,
              Icons.bar_chart,
              'Statistics',
              1,
              selectedIndex,
              context,
            ),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet,
              'Wallet',
              2,
              selectedIndex,
              context,
            ),
            _buildNavItem(
              Icons.person_outline,
              Icons.person,
              'Profile',
              3,
              selectedIndex,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    int selectedIndex,
    BuildContext context,
  ) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/statistics');
            break;
          case 2:
            context.go('/wallet');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF2F7F78) : Colors.grey.shade400,
            size: 22,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF2F7F78)
                  : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}
