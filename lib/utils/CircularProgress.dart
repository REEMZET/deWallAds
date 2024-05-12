import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context, int seconds) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading..."),
            ],
          ),
        ),
      );
    },
  );

  await Future.delayed(Duration(seconds: seconds));

  Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
}
