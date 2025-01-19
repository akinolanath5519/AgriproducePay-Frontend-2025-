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
      items: [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house, size: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.calculator, size: 24),
          label: 'Calculator',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.cartShopping, size: 24),
          label: 'Purchases',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user, size: 24),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.deepPurpleAccent,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
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
