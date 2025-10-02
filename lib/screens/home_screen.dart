import 'package:agriproduce/screens/sack_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/screens/bulkweight_screen.dart';
import 'package:agriproduce/screens/commodity_screen.dart';
import 'package:agriproduce/screens/sales_screen.dart';
import 'package:agriproduce/screens/supplier_screen.dart';
import 'package:agriproduce/widgets/analytics_card.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool isAdmin;

  const HomeScreen({Key? key, required this.isAdmin}) : super(key: key);

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
      if (widget.isAdmin)
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
        'title': 'Add Bulk Weight',
        'icon': Icons.scale,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BulkWeightScreen()),
          );
        },
      },
      {
        'title': 'Sales',
        'icon': Icons.shopping_cart,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesScreen()),
          );
        },
      },
      {
        'title': 'Sack Management',
        'icon': Icons.shopping_bag,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  SackManagementScreen()),
          );
        },
      },
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchAnalyticsData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 10),
            Text(
              user != null
                  ? 'Welcome back, ${user.name}! 👋'
                  : 'Welcome back! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.purple,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            isAnalyticsLoading
                ? SkeletonLoader(
                    builder: Container(
                      height: 200,
                      color: Colors.white,
                      child: Column(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SkeletonLoader(
                              builder: Container(
                                height: 30,
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                : AnalyticsCard(
                    title: 'Analytics Overview',
                    data: [
                      {
                        'title': 'Total Suppliers',
                        'value': suppliers.length.toString()
                      },
                      {
                        'title': 'Total Purchases',
                        'value': transactions.length.toString()
                      },
                    ],
                  ),
            const SizedBox(height: 5),
            // ✅ GridView for management options
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return GestureDetector(
                  onTap: option['onTap'] as void Function()?,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(option['icon'] as IconData,
                            size: 30, color: Colors.deepPurple),
                        const SizedBox(height: 8),
                        Text(
                          option['title'] as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
