import 'package:agriproduce/state_management/subscription_provider.dart';
import 'package:agriproduce/subscription/super_admin_renew_sub.dart';
import 'package:agriproduce/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SubscriptionManagement extends ConsumerStatefulWidget {
  const SubscriptionManagement({super.key});

  @override
  _SubscriptionManagementState createState() => _SubscriptionManagementState();
}

class _SubscriptionManagementState
    extends ConsumerState<SubscriptionManagement> {
  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    try {
      await ref
          .read(subscriptionNotifierProvider.notifier)
          .fetchSubscriptions(ref);
    } catch (error) {
      _showSnackbar('Error fetching subscriptions: $error');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _getSubscriptionStatus(DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isBefore(endDate) ? 'Active' : 'Expired';
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      body: subscriptions.when(
        data: (subscriptions) => ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index];

            // Parse subscription expiry to DateTime
            final endDate = _parseExpiryDate(subscription.subscriptionExpiry);
            final endDateFormatted = endDate != null
                ? DateFormat('yyyy-MM-dd').format(endDate)
                : 'Invalid date';
            final status =
                endDate != null ? _getSubscriptionStatus(endDate) : 'Unknown';

            return SubscriptionCard(
              endDateFormatted: endDateFormatted,
              status: status,
              onEdit: () => print('Edit subscription: ${subscription.id}'),
              onDelete: () async {
                await ref
                    .read(subscriptionNotifierProvider.notifier)
                    .deleteSubscription(ref);
                _fetchSubscriptions(); // Refresh after deletion
              },
            );
          },
        ),
        loading: () => CustomLoadingIndicator(),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load subscriptions')),
      ),
      // Add button to navigate to renew subscription screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RenewSubscriptionScreen()),
          );
        },
        tooltip: 'Renew Subscription',
        child: Icon(Icons.refresh),
      ),
    );
  }

  DateTime? _parseExpiryDate(dynamic expiry) {
    if (expiry is DateTime) {
      return expiry;
    } else if (expiry is String) {
      try {
        return DateTime.parse(expiry);
      } catch (e) {
        print('Error parsing expiry date: $e');
      }
    }
    return null; // Return null instead of a default fallback
  }
}

class SubscriptionCard extends StatelessWidget {
  final String endDateFormatted;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubscriptionCard({
    super.key,
    required this.endDateFormatted,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Subscription Status'),
      subtitle: Text('End: $endDateFormatted\nStatus: $status'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
