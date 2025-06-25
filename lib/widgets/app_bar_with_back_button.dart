import 'package:flutter/material.dart';

class AppBarWithBackButton extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppBarWithBackButton({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
