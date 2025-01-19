import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController rateController;
  final VoidCallback onSave;

  const CustomDialog({
    super.key,
    required this.title,
    required this.nameController,
    required this.rateController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Name',
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              controller: rateController,
              label: 'Rate',
              hintText: 'Enter rate',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onSave();
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
