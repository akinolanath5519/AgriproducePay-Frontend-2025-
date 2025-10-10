import 'package:agriproduce/state_management/subscription_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/data_models/subscription_plan_model.dart';

class SubscriptionPaymentPage extends ConsumerStatefulWidget {
  const SubscriptionPaymentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPaymentPage> createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState
    extends ConsumerState<SubscriptionPaymentPage> {
  SubscriptionPlan? _selectedPlan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(subscriptionPlanNotifierProvider.notifier).fetchPlans(ref);
      final plans = ref.read(subscriptionPlanNotifierProvider);
      if (plans.isNotEmpty) {
        setState(() => _selectedPlan = plans.first);
      }
    } catch (e) {
      print("Error loading plans: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _payForPlan() async {
    if (_selectedPlan == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionPlanNotifierProvider.notifier)
          .payForPlan(ref, _selectedPlan!);
    } catch (e) {
      print("Payment error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(subscriptionPlanNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: plans.isEmpty
                      ? const Center(
                          child: Text(
                            'No subscription plans found.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            final plan = plans[index];
                            final isSelected = _selectedPlan?.id == plan.id;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [Colors.green[300]!, Colors.green[100]!],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                title: Text(
                                  plan.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: plan.description != null
                                    ? Text(
                                        plan.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      )
                                    : null,
                                trailing: Text(
                                  '₦${plan.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                onTap: () => setState(() => _selectedPlan = plan),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedPlan != null ? _payForPlan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Pay & Subscribe',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
