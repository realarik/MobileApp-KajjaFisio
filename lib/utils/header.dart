import 'package:flutter/material.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final double height;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.height = 80, // default tinggi biar konsisten di semua halaman
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: height,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22, // Konsisten semua halaman!
        ),
      ),
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
