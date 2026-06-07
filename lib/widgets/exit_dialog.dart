import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showExitConfirmation(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;

  if (Platform.isIOS) {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text('Exit App?', style: TextStyle(color: cs.onSurface)),
          content: Text(
            'Are you sure you want to exit?',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: const Text('Exit'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> confirmAndExitApp(BuildContext context) async {
  final confirmed = await showExitConfirmation(context);
  if (confirmed) {
    await SystemNavigator.pop();
  }
}
