import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/providers/chat_providers.dart';
import 'package:gpt_clone/widgets/chat_view.dart';
import 'package:gpt_clone/widgets/drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatGPT',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final modelsAsync = ref.watch(modelsProvider);
              final selectedModelCode = ref.watch(selectedModelProvider);

              return modelsAsync.when(
                data: (models) {
                  // Find the full name of the selected model
                  final selectedModelName = models.firstWhere(
                      (m) => m['code'] == selectedModelCode,
                      orElse: () => {'name': 'Model'})['name']!;

                  if (Platform.isIOS) {
                    return GestureDetector(
                      onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          title: const Text('Select Model'),
                          actions: models.map((model) {
                            return CupertinoActionSheetAction(
                              onPressed: () {
                                ref.read(selectedModelProvider.notifier).state =
                                    model['code']!;
                                Navigator.pop(context);
                              },
                              child: Text(model['name']!),
                              isDefaultAction:
                                  model['code'] == selectedModelCode,
                            );
                          }).toList(),
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                            isDestructiveAction: true,
                          ),
                        ),
                      ),
                      child: Container(
                        height: 128,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              selectedModelName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            const Icon(
                              CupertinoIcons.chevron_down_circle_fill,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return PopupMenuButton<String>(
                      elevation: 10,
                      offset: Offset(-10, 48),
                      onSelected: (value) {
                        ref.read(selectedModelProvider.notifier).state = value;
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      child: Container(
                        height: 128,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(selectedModelName,
                                style: const TextStyle(fontSize: 14)),
                            Icon(Icons.keyboard_arrow_down,
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryFixedDim),
                          ],
                        ),
                      ),
                      itemBuilder: (context) {
                        return models.map((model) {
                          return PopupMenuItem<String>(
                            height: 48,
                            value: model['code'],
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: model['code']!,
                                  groupValue: selectedModelCode,
                                  onChanged: (String? value) {
                                    ref
                                        .read(selectedModelProvider.notifier)
                                        .state = value!;
                                    Navigator.of(context).pop();
                                  },
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                Text(model['name']!),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    );
                  }
                },
                loading: () => const SizedBox(),
                error: (e, s) =>
                    IconButton(icon: const Icon(Icons.error), onPressed: () {}),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: ChatHistoryPanel(),
      ),
      body: ChatView(),
      drawerScrimColor:
          Theme.of(context).colorScheme.onTertiary.withOpacity(0.5),
    );
  }
}
