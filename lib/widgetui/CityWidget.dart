import 'package:flutter/material.dart';

class CityWidget extends StatelessWidget {
  final AssetImage assetImage;
  final String label;
  final Function()? onPressed;

  const CityWidget({
    Key? key,
    required this.assetImage,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.grey[200],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Image.asset(assetImage.assetName), // Use assetImage instead of assetImage.assetName
              const SizedBox(height: 2),
              SizedBox(
                width: 80,
                height: 40,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
