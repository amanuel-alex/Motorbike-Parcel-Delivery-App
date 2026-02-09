import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';

    if (error.toString().contains('network-request-failed')) {
      message = 'No internet connection. Please check your network.';
    } else if (error.toString().contains('permission-denied')) {
      message = 'You do not have permission to perform this action.';
    } else if (error.toString().contains('deadline-exceeded')) {
      message = 'The request timed out. Please try again.';
    } else if (error != null) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
