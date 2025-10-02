// import 'package:agriproduce/screens/calculator_screen.dart';
// import 'package:agriproduce/screens/home_screen.dart';
// import 'package:agriproduce/screens/purchases_screen.dart';
// import 'package:agriproduce/screens/profile_screen.dart';
// import 'package:agriproduce/subscription/sub_manage.dart';
// import 'package:agriproduce/state_management/subscription_provider.dart';
// import 'package:agriproduce/subscription/user_sub_renewal.dart';
// import 'package:agriproduce/widgets/custom_bottom_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class Dashboard extends ConsumerStatefulWidget {
//   final bool isAdmin;

//   const Dashboard({super.key, required this.isAdmin});

//   @override
//   DashboardState createState() => DashboardState();
// }

// class DashboardState extends ConsumerState<Dashboard> {
//   int _selectedIndex = 0;

//   late final List<Widget> _allPages;
//   late final List<String> _titles;

//   @override
//   void initState() {
//     super.initState();
//     _allPages = widget.isAdmin
//         ? [
//             HomeScreen(isAdmin: true),
//             CalculatorScreen(isAdmin: true),
//             PurchasesScreen(isAdmin: widget.isAdmin),
//             ProfileScreen(),
//           ]
//         : [
//             HomeScreen(isAdmin: false),
//             CalculatorScreen(isAdmin: false),
//             PurchasesScreen(isAdmin: widget.isAdmin),
//             ProfileScreen(),
//             SubscriptionManagement(),
//           ];

//     _titles = widget.isAdmin
//         ? ['Home', 'Calculator', 'Purchases', 'Profile']
//         : ['Home', 'Calculator', 'Purchases', 'Profile', 'Subscription'];

//     // Trigger subscription fetching on initialization
//     ref.read(subscriptionNotifierProvider.notifier).fetchSubscriptions(ref);
//     print("Fetching subscriptions on init...");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final subscriptionStatus = ref.watch(subscriptionNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text(_titles[_selectedIndex])),
//       body: subscriptionStatus.when(
//         data: (subscriptions) {
//           if (subscriptions.isNotEmpty) {
//             final subscription = subscriptions.first;
//             final endDate = _parseExpiryDate(subscription.subscriptionExpiry);
//             final isActive = _isSubscriptionActive(endDate);

//             if (isActive || _isAccessibleScreen(_selectedIndex)) {
//               return _allPages[_selectedIndex];
//             } else {
//               if (_isRestrictedScreen(_selectedIndex)) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _showRenewDialog(context);
//                 });
//               }
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.lock,
//                       color: Colors.red,
//                       size: 50.0,
//                     ),
//                     SizedBox(height: 20),
//                     Center(
//                       child: Container(
//                         padding: EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               "Your subscription has expired.",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Please renew to access full features.",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade700,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             SizedBox(height: 20),
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         SubscriptionRenewalScreen(),
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.deepPurple,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 30, vertical: 15),
//                               ),
//                               child: Text(
//                                 "Renew Now",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             }
//           } else {
//             return Center(child: Text("No subscription found."));
//           }
//         },
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (error, stackTrace) =>
//             Center(child: Text("Error loading subscription status")),
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   bool _isSubscriptionActive(DateTime? endDate) {
//     return endDate != null && DateTime.now().isBefore(endDate);
//   }

//   bool _isAccessibleScreen(int index) {
//     if (widget.isAdmin) {
//       return index == 2 || index == 3;
//     } else {
//       return index == 2 || index == 3 || index == 4;
//     }
//   }

//   bool _isRestrictedScreen(int index) {
//     return index == 1;
//   }

//   void _showRenewDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Subscription Expired"),
//           content: Text(
//               "Your subscription has expired. Would you like to renew it?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SubscriptionRenewalScreen(),
//                   ),
//                 );
//               },
//               child: Text("Renew"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   DateTime? _parseExpiryDate(dynamic expiry) {
//     if (expiry is DateTime) return expiry;
//     if (expiry is String) {
//       try {
//         return DateTime.parse(expiry);
//       } catch (e) {
//         print('Error parsing expiry date: $e');
//       }
//     }
//     return null;
//   }
// }



import 'package:agriproduce/screens/calculator_screen.dart';
import 'package:agriproduce/screens/home_screen.dart';
import 'package:agriproduce/screens/purchases_screen.dart';
import 'package:agriproduce/screens/profile_screen.dart';
import 'package:agriproduce/subscription/sub_manage.dart';
import 'package:agriproduce/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Dashboard extends ConsumerStatefulWidget {
  final bool isAdmin;

  const Dashboard({super.key, required this.isAdmin});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends ConsumerState<Dashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _allPages;
  late final List<String> _titles;

  @override
  void initState() {
    super.initState();
    _allPages = widget.isAdmin
        ? [
            HomeScreen(isAdmin: true),
            CalculatorScreen(isAdmin: true),
            PurchasesScreen(isAdmin: widget.isAdmin),
            ProfileScreen(),
          ]
        : [
            HomeScreen(isAdmin: false),
            CalculatorScreen(isAdmin: false),
            PurchasesScreen(isAdmin: widget.isAdmin),
            ProfileScreen(),
            SubscriptionManagement(),
          ];

    _titles = widget.isAdmin
        ? ['Home', 'Calculator', 'Purchases', 'Profile']
        : ['Home', 'Calculator', 'Purchases', 'Profile', 'Subscription'];
  }

  @override
  Widget build(BuildContext context) {
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
