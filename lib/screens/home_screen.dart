import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/screens/bulkweight_screen.dart';
import 'package:agriproduce/screens/commodity_screen.dart';
import 'package:agriproduce/screens/sales_screen.dart';
import 'package:agriproduce/screens/supplier_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/widgets/analytics_card.dart';
import 'package:agriproduce/widgets/management_options.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/state_management/bulkweight_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool isAdmin;

  const HomeScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isAnalyticsLoading = true;

  // Fetch only analytics-related data
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
        isAnalyticsLoading = false; // Set loading state for analytics
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData(); // Fetch analytics data on init
  }

  @override
  Widget build(BuildContext context) {
    // Fetch data from providers
    final suppliers = ref.watch(supplierNotifierProvider);
    final transactions = ref.watch(transactionProvider);
    final bulkWeights = ref.watch(bulkWeightNotifierProvider);

    // Group bulk weights by transaction ID
    final Map<String, List<BulkWeight>> groupedBulkWeights = {};
    for (var bulkWeight in bulkWeights) {
      if (!groupedBulkWeights.containsKey(bulkWeight.transactionId)) {
        groupedBulkWeights[bulkWeight.transactionId] = [];
      }
      groupedBulkWeights[bulkWeight.transactionId]!.add(bulkWeight);
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Text(
            'Welcome back! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome to your agriproduce hub! Let’s cultivate progress together.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Analytics Section
          isAnalyticsLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ))
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
          const SizedBox(height: 20),
          // Management Options
          ManagementOptions(
            options: [
              {
                'title': 'Add Supplier',
                'icon': Icons.person_add,
                'onTap': () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SupplierScreen()),
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
                      MaterialPageRoute(
                          builder: (context) => const CommodityScreen()),
                    );
                  },
                },
              {
                'title': 'Bulk Weight',
                'icon': Icons.scale,
                'onTap': () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BulkWeightScreen(),
                    ),
                  );
                },
              },
              {
                'title': 'Sales',
                'icon': Icons.shopping_cart,
                'onTap': () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesScreen()),
                  );
                },
              },
            ],
          ),
        ],
      ),
    );
  }
}