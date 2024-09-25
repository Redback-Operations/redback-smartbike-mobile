import 'package:flutter/material.dart';

class AlertUtils {
  static void showAlert({
    required BuildContext context,
    String? title,
    String? message,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: message != null ? Text(message) : null,
          actions: [
            TextButton(
              onPressed: () {
                // If onOkPressed is provided, call it
                if (onOkPressed != null) {
                  onOkPressed();
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to create an overlay loader
  OverlayEntry createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: CircularProgressIndicator(), // Loader widget
          ),
        ),
      ),
    );
  }
}
