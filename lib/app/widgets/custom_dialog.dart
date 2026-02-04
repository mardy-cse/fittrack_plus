import 'package:flutter/material.dart';

class CustomDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? customContent,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: customContent ??
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onCancel?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: Text(cancelText),
              ),
            if (confirmText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDestructive ? Colors.red : const Color(0xFF4A90E2),
                ),
                child: Text(confirmText),
              ),
          ],
        );
      },
    );
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget content,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: content,
        );
      },
    );
  }
}
