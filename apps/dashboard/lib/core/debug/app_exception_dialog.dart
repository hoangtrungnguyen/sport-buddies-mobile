import 'package:flutter/material.dart';

class AppExceptionDialog extends StatelessWidget {
  const AppExceptionDialog({super.key, required this.message});

  final String message;

  static void show(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AppExceptionDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lỗi không xác định'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
