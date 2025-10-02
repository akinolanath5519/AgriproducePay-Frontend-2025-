import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionRenewalScreen extends StatelessWidget {
  final String websiteUrl = "https://www.mattwolkins.com/";
  final String whatsappNumber = "+2348106480063";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Subscription'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Choose a Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 20),
            _buildPlanOption(
              context,
              title: 'Monthly Plan',
              description: '\$5/month\nNaira Equivalent: #7,500',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            _buildPlanOption(
              context,
              title: 'Quarterly Plan',
              description:
                  '\$4.67/month\nFor 3 months: \$14\nNaira Equivalent: #21,000',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 16),
            _buildPlanOption(
              context,
              title: '6 Months Plan',
              description:
                  '\$4.33/month\nFor 6 months: \$26\nNaira Equivalent: #39,000',
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            _buildPlanOption(
              context,
              title: 'Annual Plan',
              description:
                  '\$4/month\nAnnually: \$48\nNaira Equivalent: #72,000',
              color: Colors.deepPurple,
              isRecommended: true,
            ),
            const SizedBox(height: 40),
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 10),
            _buildBankDetails(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _launchWebsite,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Center(
                child: Text(
                  'Visit Our Website',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _launchWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Center(
                child: Text(
                  'Contact us on WhatsApp',
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

  Widget _buildBankDetails() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBankDetailItem('Account Number', '1016152497', isBold: true),
            _buildBankDetailItem(
                'Account Name', 'Matt-Wolkins Global Enterprises',
                isBold: true),
            _buildBankDetailItem('Bank', 'Zenith Bank', isBold: true),
            _buildBankDetailItem(
              'Address',
              'No. 1, Beside Modern Options Filling Station, along Ogbomoso - Ikirun road, '
                  'Owode, Ogbomoso, Oyo State, Nigeria.',
              isBold: true,
            ),
            _buildBankDetailItem(
                'Email', 'support.agriproducepay@mattwolkins.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailItem(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _launchWebsite() async {
    if (await canLaunch(websiteUrl)) {
      await launch(websiteUrl);
    } else {
      throw 'Could not launch $websiteUrl';
    }
  }

  void _launchWhatsApp() async {
    final whatsappUrl = "https://wa.me/$whatsappNumber";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Widget _buildPlanOption(BuildContext context,
      {required String title,
      required String description,
      required Color color,
      bool isRecommended = false}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
          color: isRecommended ? color.withOpacity(0.1) : Colors.white,
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
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
