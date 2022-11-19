import 'package:flutter/material.dart';

class HomeFloatingActionButton extends StatelessWidget {
  final Function()? onPressed;

  const HomeFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
