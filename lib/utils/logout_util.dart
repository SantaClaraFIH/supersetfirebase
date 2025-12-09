import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../widgets/confirm_dialog.dart';

void logout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return ConfirmDialog(
        open: true,
        title: 'Logout',
        description: 'Are you sure you want to log out?',
        confirmLabel: 'Logout',
        cancelLabel: 'Cancel',
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      );
    },
  );
}
