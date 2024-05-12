import 'package:flutter/material.dart';

class LoadingDialog {
  late BuildContext _context;
  late Dialog _dialog;

  void show(BuildContext context) {
    _context = context;

    _dialog = Dialog(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Sending Inquiry..."),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return _dialog;
      },
    );
  }

  void dismiss() {
    Navigator.of(_context, rootNavigator: true).pop(); // Close the dialog
  }
}
