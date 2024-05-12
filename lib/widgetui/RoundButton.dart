import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double containerheight;
  final double containerwidth;
  final double iconsize;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.containerheight,
    required this.containerwidth,
    required this.iconsize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: containerwidth,
          height: containerheight,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: iconsize,
            ),
          ),
        ),
      ),
    );
  }
}
