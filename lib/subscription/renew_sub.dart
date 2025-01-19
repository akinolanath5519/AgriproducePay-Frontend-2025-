import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/state_management/subscription_provider.dart';

class RenewSubscriptionScreen extends ConsumerStatefulWidget {
  const RenewSubscriptionScreen({super.key});

  @override
  _RenewSubscriptionScreenState createState() =>
      _RenewSubscriptionScreenState();
}

class _RenewSubscriptionScreenState
    extends ConsumerState<RenewSubscriptionScreen> {
  final _emailController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Fetch subscriptions when the screen loads
    ref.read(subscriptionNotifierProvider.notifier).fetchSubscriptions(ref);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Subscription'),
      ),
      body: subscriptionStatus.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return const Center(
              child: Text('No subscriptions found.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Renew Subscription',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                    hintText: 'Enter the admin email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Subscription Duration (months)',
                    hintText: 'Enter subscription duration',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _renewSubscription,
                        child: const Text('Renew Subscription'),
                      ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  // Function to handle subscription renewal
  Future<void> _renewSubscription() async {
    if (_emailController.text.isEmpty || _durationController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    final adminEmail = _emailController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (duration == null || duration <= 0) {
      _showErrorDialog('Please enter a valid subscription duration.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Call the renewSubscription method
      await ref.read(subscriptionNotifierProvider.notifier).renewSubscription(
            ref,
            adminEmail,
            duration,
          );

      // On successful renewal
      _showSuccessDialog('Subscription renewed successfully!');
    } catch (e) {
      _showErrorDialog('An error occurred while renewing the subscription.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
