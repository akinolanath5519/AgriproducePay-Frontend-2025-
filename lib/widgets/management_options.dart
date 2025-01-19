import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'option_button.dart';

class ManagementOptions extends StatelessWidget {
  final List<Map<String, dynamic>> options; // E.g., [{title: 'Add Supplier', icon: Icons.add, onTap: () {}}]

  const ManagementOptions({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12.0,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Management Options',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 20.0),
            Wrap(
              spacing: 10.0,
              runSpacing: 15.0,
              children: options
                  .map(
                    (option) => OptionButton(
                      title: option['title'],
                      icon: option['icon'],
                      onTap: option['onTap'],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
