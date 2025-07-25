import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/providers/theme_providers.dart';

class ThemeSwitch extends ConsumerWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.light_mode,
            color: !isDarkMode
                ? Theme.of(context).colorScheme.primary
                : Colors.grey),
        Platform.isIOS
            ? CupertinoSwitch(
                value: isDarkMode,
                onChanged: (val) =>
                    ref.read(isDarkModeProvider.notifier).state = val,
              )
            : Switch(
                value: isDarkMode,
                onChanged: (val) =>
                    ref.read(isDarkModeProvider.notifier).state = val,
              ),
        Icon(
          Icons.dark_mode,
          color:
              isDarkMode ? Theme.of(context).colorScheme.primary : Colors.grey,
          size: 24,
        ),
      ],
    );
  }
}
