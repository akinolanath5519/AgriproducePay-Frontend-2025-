import 'package:agriproduce/screens/subscription_plan_screen.dart';
import 'package:agriproduce/utilis/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/screens/commodity_screen.dart';
import 'package:agriproduce/screens/supplier_screen.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:agriproduce/screens/sack_screen.dart';
import 'package:agriproduce/theme/app_theme.dart';

/// ✅ Reusable Analytics Card
class AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  final Color? iconColor;

  const AnalyticsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? AppColors.primary;

    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Title + Value
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: valueColor ?? AppColors.textPrimary,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isAnalyticsLoading = true;

  Future<void> _fetchAnalyticsData() async {
    try {
      final supplierState = ref.read(supplierNotifierProvider);
      final transactionState = ref.read(transactionProvider);

      if (supplierState.isEmpty) {
        await ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
      }

      if (transactionState.isEmpty) {
        await ref.read(transactionProvider.notifier).fetchTransactions(ref);
      }
    } catch (error) {
      print('Error fetching analytics data: $error');
    } finally {
      setState(() {
        isAnalyticsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierNotifierProvider);
    final transactions = ref.watch(transactionProvider);
    final user = ref.watch(userProvider);

    final bool isAdmin = user?.role == 'admin'; 

    final double totalPurchases =
        transactions.fold<double>(0, (sum, txn) => sum + txn.price);
    final int activeSuppliers = suppliers.length;

    final options = [
      {
        'title': 'Add Supplier',
        'icon': Icons.person_add,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupplierScreen()),
          );
        },
      },
      if (isAdmin)
        {
          'title': 'Add Commodity\'s Rate',
          'icon': Icons.inventory,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommodityScreen()),
            );
          },
        },
      {
        'title': 'Sack Management',
        'icon': Icons.shopping_bag,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SackManagementScreen()),
          );
        },
      },
      {
        'title': 'Payment & Subscription',
        'icon': Icons.payment,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SubscriptionPaymentPage()),
          );
        },
      },
    ];

    // ✅ List of colors for quick action icons
    final List<Color> iconColors = [
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.red,
    ];

    // ✅ Dummy recent transactions
    final dummyTransactions = [
      {"title": "Cashew Purchase", "amount": 50000, "date": "Today"},
      {"title": "Cocoa Purchase", "amount": 75000, "date": "Yesterday"},
      {"title": "Palm Kernel Purchase", "amount": 32000, "date": "2 days ago"},
    ];

    return Scaffold(
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _fetchAnalyticsData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 10),
              Text(
                user != null ? 'Good morning, ${user.name}!' : 'Good morning!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              Text(
                "Here's your trading overview for today",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // ✅ Analytics Cards
              if (isAnalyticsLoading)
                SkeletonLoader(
                  builder: Column(
                    children: List.generate(
                      2,
                      (index) => Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    AnalyticsCard(
                      icon: Icons.shopping_cart,
                      title: "Total Purchases",
                      value: "₦${totalPurchases.toFormatted()}",
                    ),
                    const SizedBox(height: 2),
                    AnalyticsCard(
                      icon: Icons.people,
                      title: "Active Suppliers",
                      value: activeSuppliers.toString(),
                      iconColor: Colors.blue,
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // ✅ Quick Actions Section
              Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final iconColor = iconColors[index % iconColors.length];

                      return Expanded(
                        child: InkWell(
                          onTap: option['onTap'] as void Function()?,
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: iconColor.withOpacity(0.1),
                                radius: 24,
                                child: Icon(
                                  option['icon'] as IconData,
                                  color: iconColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option['title'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Recent Transactions Section
              Text(
                "Recent Transactions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ...dummyTransactions.map((txn) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.shopping_cart,
                            color: Colors.green),
                      ),
                      title: Text(txn["title"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(txn["date"].toString()),
                      trailing: Text(
                        "₦${txn["amount"].toString()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
