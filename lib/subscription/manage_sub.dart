import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubscriptionRenewalScreen extends StatelessWidget {
  final String whatsappNumber = "09073699985"; // Replace with your WhatsApp number
  static const platform = MethodChannel('com.example.agriproduce/whatsapp');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Subscription'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const SizedBox(height: 20),
            // Subscription Plans
            Text(
              'Choose a Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            _buildPlanOption(
              context,
              title: 'Monthly Plan',
              description: '\$9.99 per month',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            _buildPlanOption(
              context,
              title: 'Yearly Plan',
              description: '\$99.99 per year (Save 20%)',
              color: Colors.deepPurple,
              isRecommended: true,
            ),
            const SizedBox(height: 10),
            _buildPlanOption(
              context,
              title: 'Lifetime Plan',
              description: '\$199.99 one-time payment',
              color: Colors.orange,
            ),
            const Spacer(),

            // Renew Button
            ElevatedButton(
              onPressed: () {
                _launchWhatsApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Center(
                child: Text(
                  'Renew Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    try {
      await platform.invokeMethod('openWhatsApp', {"number": whatsappNumber});
    } on PlatformException catch (e) {
      print("Failed to open WhatsApp: '${e.message}'.");
    }
  }

  Widget _buildPlanOption(BuildContext context,
      {required String title,
      required String description,
      required Color color,
      bool isRecommended = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Recommended',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}