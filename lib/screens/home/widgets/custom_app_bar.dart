import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  const CustomAppBar({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
      title: const TextField(
        decoration: InputDecoration(
          hintText: 'Search your notes..',
          border: InputBorder.none,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            // Implement sort functionality
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
