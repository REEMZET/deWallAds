import 'package:flutter/material.dart';

class Toplocationmenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function()? onPressed;

  const Toplocationmenu(
      {super.key, required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                Colors.grey[200], // Background color of the circular container
            // Set the radius to create a circle
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text(
                      label.length > 8 ? label.substring(0, 8) : label,maxLines: 2,
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
