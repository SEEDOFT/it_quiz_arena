import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:it_quiz_arena/services/audio_service.dart';

PreferredSizeWidget buildAdaptiveAppBar({
  required String title,
  required BuildContext context,
  bool showBack = true,
  List<Widget>? actions,
}) {
  final cs = Theme.of(context).colorScheme;

  void onBack() {
    AudioService().playTap();
    Navigator.maybePop(context);
  }

  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      middle: Text(title),
      leading: showBack
          ? CupertinoNavigationBarBackButton(
              onPressed: onBack,
              color: cs.primary,
            )
          : null,
      trailing: actions != null && actions.length == 1 ? actions.first : null,
      backgroundColor: cs.surface,
      border: Border(bottom: BorderSide(color: cs.outlineVariant, width: 0.5)),
    );
  }

  return AppBar(
    title: Text(title),
    backgroundColor: cs.surface,
    foregroundColor: cs.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    leading: showBack
        ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
        : null,
    actions: actions,
  );
}

Widget buildAdaptiveSwitch({
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  if (Platform.isIOS) {
    return CupertinoSwitch(value: value, onChanged: onChanged);
  }
  return Switch(value: value, onChanged: onChanged);
}

Widget buildAdaptiveSlider({
  required double value,
  required double min,
  required double max,
  int? divisions,
  required ValueChanged<double> onChanged,
}) {
  if (Platform.isIOS) {
    return CupertinoSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: onChanged,
    );
  }
  return Slider(
    value: value,
    min: min,
    max: max,
    divisions: divisions,
    label: value.toInt().toString(),
    onChanged: onChanged,
  );
}
