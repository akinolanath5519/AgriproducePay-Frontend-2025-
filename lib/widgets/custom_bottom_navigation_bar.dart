import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house, size: 22),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.calculator, size: 22),
          label: 'Calculator',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.cartShopping, size: 22),
          label: 'Purchases',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.store, size: 22),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user, size: 22),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
      backgroundColor: Colors.grey[50],
      elevation: 12,
    );
  }
}
