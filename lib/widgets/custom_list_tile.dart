import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) {
                onEdit!();
              } else if (value == 'delete' && onDelete != null) {
                onDelete!();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),
        Divider(thickness: 0.7, color: Colors.grey[300]),
      ],
    );
  }
}
