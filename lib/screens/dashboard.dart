import 'package:agriproduce/screens/calculator_screen.dart';
import 'package:agriproduce/screens/home_screen.dart';
import 'package:agriproduce/screens/purchases_screen.dart';
import 'package:agriproduce/screens/profile_screen.dart';
import 'package:agriproduce/subscription/sub_manage.dart';
import 'package:agriproduce/screens/market_place/market/marketplace_screen.dart';
import 'package:agriproduce/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/state_management/auth_provider.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends ConsumerState<Dashboard> {
  int _selectedIndex = 0;

  late List<Widget> _allPages;
  late List<String> _titles;

  @override
  void initState() {
    super.initState();
    // Pages will be initialized in build because userProvider is only accessible there
  }

  void _initPages(bool isAdmin) {
    _allPages = isAdmin
        ? [
            const HomeScreen(),
            const CalculatorScreen(),
            const PurchasesScreen(),
            const MarketplaceScreen(),
            const ProfileScreen(),
          ]
        : [
            const HomeScreen(),
            const CalculatorScreen(),
            const PurchasesScreen(),
            const MarketplaceScreen(),
            const ProfileScreen(),
            const SubscriptionManagement(),
          ];

    _titles = isAdmin
        ? ['Home', 'Calculator', 'Purchases', 'Marketplace', 'Profile']
        : ['Home', 'Calculator', 'Purchases', 'Marketplace', 'Profile', 'Subscription'];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final bool isAdmin = user?.role == 'admin';

    // Initialize pages based on user role
    _initPages(isAdmin);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _allPages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
