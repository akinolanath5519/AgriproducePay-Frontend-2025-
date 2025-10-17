import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/state_management/subscription_plan_provider.dart';
import 'package:agriproduce/data_models/subscription_plan_model.dart';
import 'package:agriproduce/theme/app_theme.dart';

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
      debugPrint("Error loading plans: $e");
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

    // ✅ Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment successful for ${_selectedPlan!.name} 🎉',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // ✅ Redirect to Home Page after 1 second (to allow user see the success message)
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

  } catch (e) {
    debugPrint("Payment error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment failed. Please try again.'),
        backgroundColor: AppColors.error,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(subscriptionPlanNotifierProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== AppBar Section =====
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.primary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Subscription Plans',
                            style: AppText.appTitle,
                          ),
                          const SizedBox(width: 40), // spacing placeholder
                        ],
                      ),
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        "Choose the plan that fits your business",
                        textAlign: TextAlign.center,
                        style: AppText.subtitle,
                      ),
                    ),

                    // ===== Plans List =====
                    Expanded(
                      child: plans.isEmpty
                          ?  Center(
                              child: Text(
                                'No subscription plans found.',
                                style: AppText.body,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                final isSelected =
                                    _selectedPlan?.id == plan.id;

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPlan = plan),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          AppBorderRadius.medium,
                                      gradient: isSelected
                                          ? AppColors.primaryGradient
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white,
                                      boxShadow: const [AppShadows.subtle],
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                        width: 1.3,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .workspace_premium_rounded,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.primary,
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  plan.name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors
                                                            .textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '₦${plan.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AppColors.goldAccent
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          plan.description ??
                                              "Enjoy premium access and features.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Colors.white70
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.successGreen,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Instant activation",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isSelected
                                                    ? Colors.white70
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // ===== Pay Button =====
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading || _selectedPlan == null
                              ? null
                              : _payForPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                            shadowColor:
                                AppColors.primary.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Pay ₦${_selectedPlan?.price.toStringAsFixed(2) ?? ''} & Subscribe',
                                  style: AppText.button,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
